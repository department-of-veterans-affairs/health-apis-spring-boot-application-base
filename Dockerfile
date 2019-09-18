
FROM centos:latest

RUN yum update -yqq \
    && yum install -yqq yum-utils \
    && yum install -yqq gettext openssh-clients git \
    && yum install -yqq zip unzip \
    && yum install -yqq dos2unix \
    && yum install -yqq docker \
    && yum clean all

#
# JQ
#
RUN curl -skLo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
    && chmod +x /usr/local/bin/jq
