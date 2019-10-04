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

buildTestApplication(){

  case "$1" in
    8) buildTestApplicationJDK8 ;;
    12) buildTestApplicationJDK12 ;;
    *) echo "Unknown version: $VERSION. Supported versions are 8 and 12." && exit 1 ;;
  esac
}

buildTestApplicationJDK8(){
  echo "WE DONT HAVE A WAY TO TEST JDK 8"
}

buildTestApplicationJDK12(){
  dockerRepo=vasdvp/health-apis-spring-boot-application-base
  echo "Building local docker image to test"
  #going to need to figure out how to do this.  Probably want to pull down an easy repo (IDS for jdk-12?).
  clone-repo "health-apis-mock-eligibility-and-enrollment"

  echo 'it finished cline-repo script?'

  MVN_ARGS="--settings $WORKSPACE/settings.xml --batch-mode \
            -Ddocker.username=$DOCKER_USERNAME -Ddocker.password=$DOCKER_PASSWORD \
            -Dvasdvp-releases.nexus.user=$VASDVP_RELEASES_NEXUS_USERNAME -Dvasdvp-releases.nexus.password=$VASDVP_RELEASES_NEXUS_PASSWORD \
            -Dhealth-apis-releases.nexus.user=$HEALTH_APIS_RELEASES_NEXUS_USERNAME -Dhealth-apis-releases.nexus.password=$HEALTH_APIS_RELEASES_NEXUS_PASSWORD"
  #
  # By default, we'll automatically upgrade gov.va.dvp. But if this project belongs
  # do a different group, we'll also want to upgrade that too.
  #

  mvn $MVN_ARGS clean install io.fabric8:docker-maven-plugin:build -Ddocker.baseImage=$dockerRepo -Ddocker.baseVersion='jdk-12-sec-scan' -Ddocker.imageName="health-apis-mock-eligibility-and-enrollment-canary" -Ddocker.tag="sec-scan" -Prelease

  docker images
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
  8) buildTestApplication 8 ;;
  12) buildTestApplication 12 ;;
  *) echo "Unknown version: $VERSION. Supported versions are 8 and 12." && exit 1 ;;
esac
