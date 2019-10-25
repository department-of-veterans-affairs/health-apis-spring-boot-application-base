#!/usr/bin/env bash


#
# Ensure that we fail fast on any issues.
#
set -euo pipefail

doUpgrade() {
  dockerRepo=vasdvp/health-apis-spring-boot-application-base
  tag=jdk-$1
  sectag=$1-sec-scan

  docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
  docker build -f Dockerfile$1 --build-arg CACHBREAKER=$(date +%D)_spring_boot_application_base -t $1:$2 .
  docker push $1:$2
}

doUpgrade 8 ;;
doUpgrade 12 ;;

