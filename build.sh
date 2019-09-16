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

doUpgrade() {
  dockerRepo=vasdvp/health-apis-spring-boot-application-base
  tag=$1
  sectag=$1-sec-scan

  #Check to see if there are vulnerabilities in the image.
  checkForVulnerabilities
  
  #Build the new spring-boot-application-base
  doDockerBuild $dockerRepo $sectag
  
  #Push the sectag to DockerHub
  doDockerPush $dockerRepo $sectag
  
  #give the image 30 sec before we pull it down to use it.
  #sleep 30
  
  #Build the Test Application for the specific version
  buildTestApplication

  #Test the application that was just launched.  For a specific version
  #testApplication

  #Tag the sectag as the regular tag
  #retagDockerImage $dockerRepo $sectag $tag

  #Push to repo with real tag
  #doDockerPush $dockerRepo $tag
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

buildTestApplication(){
  echo "Building local docker image to test"
  #going to need to figure out how to do this.  Probably want to pull down an easy repo (IDS for jdk-12?).
  cd $WORKSPACE
  git clone https://github.com/department-of-veterans-affairs/health-apis-ids.git
  cd $WORKSPACE/health-apis-ids
  mvn clean install io.fabric8:docker-maven-plugin:build -Ddocker.baseImage=$dockerRepo -Ddocker.baseVersion=$sectag -Prelease

  docker images
  #this will create a local docker image.  WIll need to figure out how to launch it standalone to do any kind of testing....]
}

testApplication(){
  #will require different applications per spring-boot-application-base (8 and 12?)?
  #Test the local docker image.  Running some kind of deploy-local.sh and test-local.sh
  #if it passes then we are good
  echo $tag
}

retagDockerImage(){
  docker tag $1:$2 $1:$3
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
