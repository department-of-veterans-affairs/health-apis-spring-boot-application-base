#!/usr/bin/env bash


#
# Ensure that we fail fast on any issues.
#
set -euo pipefail

doUpgrade() {
  dockerRepo=vasdvp/health-apis-spring-boot-application-base
  sectag=jdk-$1-rc
  date=$(date +%D)

  docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
  docker build --build-arg CACHEBREAKER=$date-spring_boot_application_base -f Dockerfile$1 -t $dockerRepo:$sectag .
  #Push to repo with release candidate tag
  docker push $dockerRepo:$sectag

  #Retag image with VERSION and push with version tag
  docker tag $dockerRepo:$sectag $dockerRepo:$VERSION
  docker push $dockerRepo:$VERSION
}

doUpgrade 8
doUpgrade 12

