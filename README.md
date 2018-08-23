Jenkins Agent Docker image
===

## Getting started

You should create host volumes for workspace and development
environment, which are not part of the Docker image.
They will be mounted in the Docker container at runtime.

```bash
# be careful the arguments order is important
sudo docker build -t pollen-metrology/jenkins_slave_v3 .
sudo docker run  \
        -d \
        -v pollen-dev-env:/home/pollen  \
        -v jenkins_workspace:/home/jenkins/workspace \
        pollen-metrology/jenkins_slave_v3 \
        -url [master server] \
        -workDir=/home/jenkins/agent \
        <agent secret hash> \
        <agent name>
```
~


## Specifications

* based on Ubuntu 18.04
* install and start ssh server
* install java, download slave.jar and connect to jenkins server
* install python dependencies
* install g++ compiler and cmake
* install node (v8.x)
* install yarn (last version)

## More

Freely inspired by:
* https://github.com/shufo/jenkins-slave-ubuntu/blob/master/Dockerfile
* https://github.com/jenkinsci/docker-slave
* https://github.com/jenkinsci/docker-jnlp-slave
