#!/usr/bin/env bash


#
# Ensure that we fail fast on any issues.
#
set -euo pipefail

doUpgrade() {
  dockerRepo=vasdvp/health-apis-spring-boot-application-base
  sectag=jdk-$1-rc
  date=$(date +%D)

  echo $date
  #docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
  docker build --build-arg CACHEBREAKER=$date-spring_boot_application_base -f Dockerfile$1 -t $dockerRepo:$sectag .
  docker push $dockerRepo:$sectag
}

doUpgrade 8
doUpgrade 12

