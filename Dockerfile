FROM centos:latest

RUN yum update -y -q -q \
    && yum install -y -q -q yum-utils \
    && yum install -y -q -q gettext openssh-clients git \
    && yum install -y -q -q zip unzip \
    && yum install -y -q -q dos2unix \
    && yum clean all


#Docker
RUN curl -fskLS https://get.docker.com | sh


#
# JQ
#
RUN curl -skLo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
    && chmod +x /usr/local/bin/jq

RUN yum install -yqq openssl

RUN mkdir /home/jenkins
