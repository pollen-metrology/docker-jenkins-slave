Jenkins Agent Docker image
===

## Getting started

```bash
# be careful the arguments order is important
docker build -t jenkins_slave .
docker run jenkins_slave -url <url> <secret> <agent name>
```

## Specifications

* based on Ubuntu 16.04
* install and start ssh server
* install java, download slave.jar and connect to jenkins server
* install python dependencies
* install g++ compiler and cmake
* install latex libraries
* install node (v8.x)
* install yarn (last version)
* create a new sudoer user jenkin

## More

Freely inspired by:
* https://github.com/shufo/jenkins-slave-ubuntu/blob/master/Dockerfile
* https://github.com/jenkinsci/docker-slave
* https://github.com/jenkinsci/docker-jnlp-slave
