#The MIT License
#
#  Copyright (c) 2015-2018, CloudBees, Inc. and other Jenkins contributors
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

FROM ubuntu:16.04
MAINTAINER Thibault Friedrich <thibault.friedrich@pollen-metrology.com>

# https://docs.docker.com/get-started/part2/#build-the-app
# https://github.com/shufo/jenkins-slave-ubuntu/blob/master/Dockerfile
# https://github.com/jenkinsci/docker-slave
# https://github.com/jenkinsci/docker-jnlp-slave

RUN apt-get update

# Install JDK 7 (latest edition)
RUN apt-get install -y --no-install-recommends default-jdk

# Install utilities
RUN apt-get install -y git wget curl python-virtualenv python-pip build-essential python-dev graphviz locales locales-all

RUN apt install -y libeigen3-dev libxt-dev libtiff-dev libpng-dev libjpeg-dev libopenblas-dev \
	xvfb libusb-dev

# QT5 development
RUN apt install -y qttools5-dev-tools libqt5opengl5-dev libqt5svg5-dev \
libqt5webkit5-dev libqt5xmlpatterns5-dev libqt5xmlpatterns5-private-dev \
qt5-default qtbase5-dev qtbase5-dev-tools qtchooser \
qtdeclarative5-dev qtscript5-dev qttools5-dev qttools5-private-dev \
libqt5websockets5-dev

# Install compilation utilities
RUN apt-get install -y g++-5 cmake lsb-core doxygen lcov

# Install LaTex environment needed for documentation compilation
RUN apt install -y texlive texlive-base texlive-bibtex-extra texlive-binaries texlive-extra-utils \
texlive-font-utils texlive-fonts-recommended texlive-generic-extra texlive-generic-recommended \
texlive-lang-french texlive-latex-base texlive-latex-extra texlive-latex-recommended \
texlive-pictures texlive-pstricks texlive-science biber latexmk

# Install last fresh cppcheck binary
RUN apt install -y libpcre3-dev
RUN cd / tmp && wget https://github.com/danmar/cppcheck/archive/1.82.tar.gz;  \
	tar zxvf 1.82.tar.gz && \
	cd cppcheck-1.82 && \
	make SRCDIR=build CFGDIR=/usr/bin/cfg HAVE_RULES=yes && \
	make install PREFIX=/usr CFGDIR=/usr/share/cppcheck/ && \
	cd .. && \
	rm -rf 1.82.tar.gz cppcheck-1.82


# Install node
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# Install yarn
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install yarn

# Install chrome
RUN apt-get install -y chromium-browser
RUN update-alternatives --install /usr/bin/chrome chrome-browser /usr/bin/chromium-browser 100

#### CHECK

# Add user jenkins to the image
RUN adduser --system --quiet jenkins --firstuid 2000 

# Install Phabricator-related tools
RUN apt install -y php7.0-cli php7.0-curl
RUN mkdir -p /home/phabricator
RUN cd /home/phabricator && git clone https://github.com/phacility/arcanist.git
RUN cd /home/phabricator && git clone https://github.com/phacility/libphutil.git

# Hack for multiplatform support of Phabricator Jenkins plugin
RUN mv /home/phabricator/arcanist/bin/arc.bat /home/phabricator/arcanist/bin/arc.bat.old
RUN ln -s /home/phabricator/arcanist/bin/arc /usr/bin/arc.bat

ARG VERSION=3.15
ARG AGENT_WORKDIR=/home/jenkins/agent

RUN curl --create-dirs -sSLo /usr/share/jenkins/slave.jar https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar \
  && chmod 755 /usr/share/jenkins \
  && chmod 644 /usr/share/jenkins/slave.jar

# USER jenkins
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
RUN mkdir /home/jenkins/.jenkins && mkdir -p ${AGENT_WORKDIR}

VOLUME /home/jenkins/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR /home/jenkins

RUN mkdir -p /home/pollen && ln -s /home/pollen /pollen

# If you put this label at the beginning of the Dockerfile, docker seems to use cache and build fails more often
LABEL Description="This is a base image, which provides the Jenkins agent executable (slave.jar)" Vendor="Jenkins project" Version="3.15"

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8


COPY jenkins-slave.sh /usr/bin/jenkins-slave.sh
RUN chmod +x /usr/bin/jenkins-slave.sh

ENTRYPOINT ["/usr/bin/jenkins-slave.sh"]
