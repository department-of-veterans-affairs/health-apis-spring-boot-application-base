FROM centos:latest

RUN yum update -y -q -q \
    && yum install -y -q -q yum-utils \
    && yum install -y -q -q gettext openssh-clients git \
    && yum install -y -q -q zip unzip \
    && yum install -y -q -q java-1.8.0-openjdk-devel \
    && yum install -y -q -q dos2unix \
    && yum clean all


#
# MAVEN 3.6
# Lots of steps to get it to work
#

RUN yum install wget -y -q -q

RUN wget https://www-us.apache.org/dist/maven/maven-3/3.6.2/binaries/apache-maven-3.6.2-bin.tar.gz -P /tmp \
    && tar xf /tmp/apache-maven-3.6.2-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-3.6.2 /opt/maven
 
ENV JAVA_HOME=/usr/lib/jvm/jre-openjdk
ENV M2_HOME=/opt/maven 
ENV MAVEN_HOME=/opt/maven 
ENV PATH=${M2_HOME}/bin:${PATH}


#
#Docker
#

RUN curl -fskLS https://get.docker.com | sh

#
# JQ
#
RUN curl -skLo /usr/local/bin/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 \
    && chmod +x /usr/local/bin/jq

RUN yum install -yqq openssl

RUN mkdir /home/jenkins && chown 1000:1000 home/jenkins
