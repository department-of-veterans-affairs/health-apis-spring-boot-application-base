This project is a standalone repo for the Docker Base Images for Spring Boot Application Bases.

The build.sh script will rebuild all versions of the Spring Boot Application Base that are currently available (for now 8 and 12).  

These rebuilt bases will be pushed to vasdvp/health-apis-spring-boot-application-base:jdk-{version}-rc.

From there they will be tested by other jobs in the pipeline.