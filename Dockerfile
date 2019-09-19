FROM centos:latest

RUN yum update -y -q -q \
    && yum install -y -q -q yum-utils \
    && yum install -y -q -q gettext openssh-clients git \
    && yum install -y -q -q zip unzip \
    && yum install -y -q -q dos2unix \
    && yum install -y -q -q docker \
    && yum clean all

#
# JQ
#
RUN curl -skLo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
    && chmod +x /usr/local/bin/jq

RUN mkdir /home/jenkins && chown 1000:1000 /home/jenkins
