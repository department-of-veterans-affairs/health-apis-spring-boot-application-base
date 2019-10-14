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

echo $WORKSPACE

doUpgrade() {
  dockerRepo=vasdvp/health-apis-spring-boot-application-base
  tag=$1
  sectag=$1-sec-scan

  docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

  #Check to see if there are vulnerabilities in the image.
  checkForVulnerabilities
  
  #Build the new spring-boot-application-base
  doDockerBuild $dockerRepo $sectag
  
  #Push the sectag to DockerHub
  doDockerPush $dockerRepo $sectag
}

checkForVulnerabilities(){
  echo "check base for vulnerabilities"
  source check_base_for_vulnerabilities $dockerRepo $tag
  
  test -n $REBUILD_STATUS

  if [ $REBUILD_STATUS == true ]
  then 
    echo "There ARE vulnerabilities to patch"
  else
    echo "There ARE NO vulnerabilities to patch"
    exit 0
  fi
}

doDockerBuild(){
  #Build local docker image with the custom tag
  docker build -f Dockerfile$VERSION -t $1:$2 .
}

doDockerPush(){
  #Push docker image
  docker push $1:$2
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
  8) doUpgrade jdk-8 ;;
  12) doUpgrade jdk-12 ;;
  *) echo "Unknown version: $VERSION. Supported versions are 8 and 12." && exit 1 ;;
esac
