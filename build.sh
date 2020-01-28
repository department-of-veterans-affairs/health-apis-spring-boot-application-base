#!/usr/bin/env bash
set -euo pipefail

BASEDIR=$(dirname $0)
CACHEBREAKER=$(date +%F)
RELEASE=${RELEASE:-false}
REPOSITORY=vasdvp/health-apis-spring-boot-application-base
VERSION=${VERSION:-$(cat $BASEDIR/VERSION)}

#
# NOTE: we do not use jdk < 12 at this time so at this point only
# performing release candidate health-apis-base-upgrader testing on 12+ builds.
#
do_build() {
  local java_version=$1
  case "$java_version" in
    8) local tags=(jdk-8) ;;
    12) local tags=(jdk-12-rc) ;;
    13) local tags=(jdk-13) ;;
    *) echo "Unknown Java version: $java_version. Supported versions are 8, 12, 13." && exit 1 ;;
  esac
  docker build \
    --build-arg CACHEBREAKER=$CACHEBREAKER \
    -f $BASEDIR/Dockerfile$java_version \
    $(sed "s#\([^ ]\+\)#-t $REPOSITORY:\1-$VERSION#g" <<< ${tags[@]}) \
    $BASEDIR
  if [ $RELEASE == true ]; then
    docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
    for tag in "${tags[@]}"; do
      docker tag $REPOSITORY:$tag-$VERSION $REPOSITORY:$tag
      docker rmi $REPOSITORY:$tag-$VERSION
      docker push $REPOSITORY:$tag
    done
  fi
}

if [ $# == 0 ]; then
  do_build 8
  do_build 12
  do_build 13
else
  do_build $1
fi
