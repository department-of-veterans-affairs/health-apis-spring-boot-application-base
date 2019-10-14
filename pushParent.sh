#!/usr/bin/env bash

#
# Disable debugging unless explicitly set
#
set +x
if [ -z "$DEBUG" ]; then DEBUG=false; fi
export DEBUG
if [ "${DEBUG}" == true ]; then
  set -x
  env | sort
fi

#
# Ensure that we fail fast on any issues.
#
set -euo pipefail

#
# Make our utilities available on the path
#
export PATH=$WORKSPACE/bin:$PATH

pushParent(){

  case "$1" in
    8) pushParentJDK8 ;;
    12) pushParentJDK12 ;;
    *) echo "Unknown version: $VERSION. Supported versions are 8 and 12." && exit 1 ;;
  esac
}

pushParentJDK8(){
  echo "WE DONT HAVE A WAY TO TEST JDK 8"
}

pushParentJDK12(){
  docker tag vasdvp/health-apis-spring-boot-application-base:jdk-12-sec-scan vasdvp/health-apis-spring-boot-application-base:jdk-12
  docker push vasdvp/health-apis-spring-boot-application-base:jdk-12
}

if [ "$APPLICATION_BASE_VERSION" == "none" ]
then
  echo "Spring Boot Appication Base Upgrade"
  echo "Nothing Built"
  echo "Nothing Pushed"
  echo "This job really just did nothing"
  echo "\" I'm just trying to do as little as possible \" - My Hero"
  exit 0
else
  VERSION=$APPLICATION_BASE_VERSION
fi 

echo "version: $VERSION"

case "$VERSION" in
  8) pushParent 8 ;;
  12) pushParent 12 ;;
  *) echo "Unknown version: $VERSION. Supported versions are 8 and 12." && exit 1 ;;
esac