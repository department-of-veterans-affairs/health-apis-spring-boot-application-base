# Spring Boot Application Base

Spring Boot application base Docker images.

## Supported Builds
The following builds are supported.
- Java 8 (`jdk-8`)
- Java 12 (`jdk-12`)

## Build Process
Run `build.sh [8|12]` to generate images. Omit version to build all supported images.

Tags will be appended with _-$VERSION_ (e.g. `jdk-12-1.1.0-SNAPSHOT`). This is done primarily to prevent Jenkins from using a pre-release image to build any applications.

Upon release, images will be retagged to remove _-$VERSION_ and pushed to Docker Hub.
