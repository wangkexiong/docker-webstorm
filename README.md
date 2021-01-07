# Docker image: wangkexiong/webstorm
![Docker Build Badge](https://github.com/wangkexiong/docker-webstorm/workflows/Docker%20Build/badge.svg)
![License](https://img.shields.io/github/license/wangkexiong/docker-webstorm)

![2020.3.1](https://img.shields.io/docker/v/wangkexiong/webstorm/2020.3.1?style=social)

## Running

  * Node.js&reg; are managed by [NVM][]
  * Set DISPLAY environment variable in .env file
  * To use mirror of node binaries, set NVM_NODEJS_ORG_MIRROR in .env file
  * Start webstorm with memory heap size 2048m
  * Webstorm workspace is set to /root/workspace
  * Webstorm configuration files and workspace are rsync to /backup

```bash
$ dcoker run -it --name webstorm --env-file ./.env -v $PWD:/backup wangkexiong/webstorm -m 2048m -s /backup
```

  [NVM]: https://github.com/nvm-sh/nvm