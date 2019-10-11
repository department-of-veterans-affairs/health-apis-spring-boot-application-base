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
  clone repo 'health-apis-mock-eligibility-and-enrollment-deployment'

  sleep 60

  # Run the docker image with the configs ^
  docker run \
    --rm \
    --network host \
    'vasdvp/health-apis-mock-ee-test:latest' \
    'regression-test' \
    --base-path='' \
    --endpoint-domain-name=localhost \
    --username=$MOCK_EE_USERNAME \
    --password=$MOCK_EE_PASSWORD \
    --icn=42
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