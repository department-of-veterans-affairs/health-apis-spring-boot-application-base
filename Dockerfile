FROM maven:3.6-jdk-12

RUN yum update -y -q -q \
    && yum install -y -q -q git \
    && yum clean all