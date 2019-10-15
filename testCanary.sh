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

testApplication(){

  case "$1" in
    8) testApplicationJDK8 ;;
    12) testApplicationJDK12 ;;
    *) echo "Unknown version: $VERSION. Supported versions are 8 and 12." && exit 1 ;;
  esac
}

testApplicationJDK8(){
  echo "WE DONT HAVE A WAY TO TEST JDK 8"
}

testApplicationJDK12(){
  #Launch mock-ee.  Write in fake username and password

  #This is important for multiple reasons.  
  # - It gets the containerID of the running image so it can be stopped later
  # - It removes itself after its been stopped
  # - It binds the container to listen on port 9090 on the machine
  # - It overwrites the entrypoint to run a bash command that then populates fake properties and then runs
  # the REAL entrypoint script
  CONTAINER_ID=$(docker run \
    --rm \
    -p 9090:9090 \
    -d \
    --entrypoint '/bin/bash' \
    vasdvp/health-apis-mock-eligibility-and-enrollment-canary:sec-scan \
    -c 'echo -e "ee.header.username=test\nee.header.password=test" > /opt/va/application.properties; \
    /tmp/entrypoint.sh')
  
  echo "Running container: $CONTAINER_ID"

  docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD

  # Pull the docker image for the mock-ee-test suite
  docker pull 'vasdvp/health-apis-mock-ee-tests:latest'

  sleep 60

  # Run the docker image with the required args
  # IF THE ARGS CHANGE THIS DOES TOO
  # --network host is NEEDED for this to be able to connect the canary on port 9090.
  # This username and password MUST match username and password in mock-ee-canary ^^
  docker run \
    --rm \
    --network host \
    'vasdvp/health-apis-mock-ee-tests:latest' \
    'regression-test' \
    --base-path='' \
    --endpoint-domain-name=http://localhost:9090 \
    --environment=local \
    --username=test \
    --password=test \
    --icn=42

  #What if the tests fail... This line will never run and the container wont stop...
  docker stop $CONTAINER_ID

  #Re-tag and push the image
  docker tag vasdvp/health-apis-spring-boot-application-base:jdk-12-sec-scan vasdvp/health-apis-spring-boot-application-base:jdk-12
  #docker push vasdvp/health-apis-spring-boot-application-base:jdk-12

  #clean up time
  docker rmi -f vasdvp/health-apis-mock-eligibility-and-enrollment-canary:sec-scan
  docker rmi -f vasdvp/health-apis-spring-boot-application-base:jdk-12-sec-scan
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
  8) testApplication 8 ;;
  12) testApplication 12 ;;
  *) echo "Unknown version: $VERSION. Supported versions are 8 and 12." && exit 1 ;;
esac