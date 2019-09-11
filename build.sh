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
#export PATH=$WORKSPACE/bin:$PATH

doUpgrade() {
  dockerRepo=vasdvp/health-apis-spring-boot-application-base
  tag=$1
  sectag=$1-sec-scan
  
  #Build the new spring-boot-application-base
  doDockerBuild
  
  #Push the sectag to DockerHub
  doDockerPush $sectag
  
  #give the image 30 sec before we pull it down to use it.
  sleep 30
  
  #Build the Test Application for the specific version
  buildTestApplication

  #Test the application that was just launched.  For a specific version
  testApplication

  #Tag the sectag as the regular tag
  retagDockerImage

  #Push to repo with real tag
  #doDockerPush $tag
}

doDockerBuild(){
  #Build local docker image with the custom tag
  docker build -f Dockerfile$VERSION -t $dockerRepo:$sectag .
}

doDockerPush(){
  #Push docker image
  docker push vasdvp/health-apis-spring-boot-application-base:$1
}

buildTestApplication(){
  #going to need to figure out how to do this.  Probably want to pull down an easy repo (IDS for jdk-12?). 
  #mvn clean install -Ddocker.baseImage=$dockerRepo -Ddocker.baseVersion=$sectag -Prelease
  #this will create a local docker image.  WIll need to figure out how to launch it standalone to do any kind of testing....]
  
  echo $tag
}

testApplication(){
  #will require different applications per spring-boot-application-base (8 and 12?)?
  #Test the local docker image.  Running some kind of deploy-local.sh and test-local.sh
  #if it passes then we are good
  echo $tag
}

retagDockerImage(){
  docker tag $dockerRepo:$sectag $dockerRepo:$tag
}

if [ "$APPLICATION_BASE_VERSION" == "none" ]
then
  echo "Spring Boot Appication Base Upgrade"
  echo "Nothing Built"
  echo "Nothing Pushed"
  echo "This job really just did nothing"
  echo "\" I'm just trying to do as little as possible \" - My Hero"
  exit 0
fi 

VERSION = $APPLICATION_BASE_VERSION

case VERSION in
  8) doUpgrade jdk-8 ;;
  12) doUpgrade jdk-12 ;;
  *) echo "Unknown version: $VERSION. Supported versions are 8 and 12." && exit 1 ;;
esac
