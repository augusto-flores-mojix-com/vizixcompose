# Vizix Compose

`ViZix Compose` is a set of tools to deploy `ViZix` and `Docker` on cloud servers like `AWS`, `Packet` and `DigitalOcean`. It already defines some default configurations for `Docker`, configurations and optimizations for `ViZix` and it includes useful tools like `docker-compose`, `htop` and `ctop`.

The automated installation comes with:

* [Ubuntu 16.04 LTS](http://releases.ubuntu.com/16.04/) (Xenial Xerus)
* Docker 17.12 CE
* [docker-compose 1.16](https://github.com/docker/compose/releases/tag/1.16.1)
* [ctop 0.6.1](https://github.com/bcicen/ctop/releases/tag/v0.6.1)
* `htop`, `nano`, `vi` and other basic Linux tools

This defaults have been decided after more than 2 years of experimenting with Docker and ViZix together. It's currently the stack running for production servers.

The purpose of having standard installation steps and OS configuration is to ease troubleshooting procedures minimizing installation settings.

## FAQ
- *I want to update the data retention time on kafka, do we have a tool for this?*

Yes, we have, use the following:
```sh
$ docker-compose -f vizix-tools.yml run -e "VIZIX_KAFKA_DATA_RETENTION_MS=172800000" -e "VIZIX_KAFKA_ZOOKEEPER=zookeeper:2181" vizix-tools updatedataretention
```
If you already have the environment variables set on vizix tools file, just use this:
```sh
$ docker-compose -f vizix-tools.yml run vizix-tools updatedataretention
```
