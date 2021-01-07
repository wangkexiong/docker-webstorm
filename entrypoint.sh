#!/bin/bash

while getopts "s:m:u:g:" arg; do
  case ${arg} in
  s)
      SYNC_DEST=${OPTARG}
      ;;
  m)
      JVM_HEAP=${OPTARG}
      ;;
  u)
      SYNC_UID=${OPTARG}
      ;;
  g)
      SYNC_GID=${OPTARG}
      ;;
  *)
      continue
      ;;
  esac
done

SYNCJOB() {
  CONF_DIR="$1"
  DEST_DIR="$2"
  SYNC_DIR="${DEST_DIR}/$(basename ${CONF_DIR})"
  SNAPSHOT="${DEST_DIR}/snapshot/$3"

  CHOWN_MODE=
  if [ -n "${SYNC_UID}" ] || [ -n "${SYNC_GID}" ]; then
    CHOWN_MODE="--chown=${SYNC_UID}:${SYNC_GID}"
  fi

  if [ -d "${CONF_DIR}" ]; then
    if [ -d "${SYNC_DIR}" ]; then
      mkdir -p "${SNAPSHOT}"
      [ -n "${SYNC_UID}" ] && chown -R ${SYNC_UID} $(dirname "${SNAPSHOT}")
      [ -n "${SYNC_GID}" ] && chown -R :${SYNC_GID} $(dirname "${SNAPSHOT}")

      rsync -avh ${CHOWN_MODE} $(realpath "${SYNC_DIR}") "${SNAPSHOT}"
      rm -rf "${SYNC_DIR}"
    fi

    rsync -avh ${CHOWN_MODE} $(realpath "${CONF_DIR}") "${DEST_DIR}"
  else
    if [ -d "${SYNC_DIR}" ]; then
      rsync -avh "${SYNC_DIR}" $(dirname "${CONF_DIR}")
    fi
  fi

  mkdir -p "${CONF_DIR}"
  while inotifywait -r -e modify,create,delete,move "${CONF_DIR}"; do
    rsync -avh --delete ${CHOWN_MODE} $(realpath "${CONF_DIR}") "${DEST_DIR}"
  done
}

## Adjust memory settings
if [ -n "${JVM_HEAP}" ]; then
  CONF_FILE=/opt/jetbrain/bin/webstorm64.vmoptions

  sed -i "s/-Xms.*/-Xms${JVM_HEAP}/" "${CONF_FILE}"
  sed -i "s/-Xmx.*/-Xmx${JVM_HEAP}/" "${CONF_FILE}"
fi

## World share
if [ -n "${SYNC_DEST}" ]; then
  TIMESTAMP=$(date +%Y%m%d%H%M%S)
  SYNCJOB /root/.config   "${SYNC_DEST}" "${TIMESTAMP}" &
  SYNCJOB /root/workspace "${SYNC_DEST}" "${TIMESTAMP}" &
fi

/opt/jetbrain/bin/webstorm.sh
