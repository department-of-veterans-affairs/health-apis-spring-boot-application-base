def saunter(scriptName, version) {
  withCredentials([
    usernameColonPassword(
      credentialsId: 'GITHUB_USERNAME_PASSWORD',
      variable: 'GITHUB_USERNAME_PASSWORD'),
    usernamePassword(
      credentialsId: 'DOCKER_USERNAME_PASSWORD',
      usernameVariable: 'DOCKER_USERNAME',
      passwordVariable: 'DOCKER_PASSWORD'),
    string(
      credentialsId: 'DOCKER_SOURCE_REGISTRY',
      variable: 'DOCKER_SOURCE_REGISTRY'),
  ]) {
    sh script: scriptName
  }
}

def sendDeployMessage(channelName, version) {
  slackSend(
    channel: channelName,
    color: '#4682B4',
    message: "Building spring-boot-application-base ${version} - ${env.JOB_NAME} ${env.BUILD_NUMBER}"
  )
}

final DOCKER_ARGS = "--privileged --group-add 497 -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v /data/jenkins/.m2/repository:/root/.m2/repository -v /var/lib/jenkins/.ssh:/root/.ssh -v /var/run/docker.sock:/var/saunter/docker.sock -v /var/lib/docker:/var/lib/docker -v /etc/docker/daemon.json:/etc/docker/daemon.json"

pipeline {
  options {
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '99', artifactNumToKeepStr: '99'))
    retry(0)
    timeout(time: 1440, unit: 'MINUTES')
    timestamps()
  }
  parameters {
    booleanParam(name: 'DEBUG', defaultValue: false, description: "Enable debugging output")
    choice(name: 'VERSION', choices: ['8','12'], description: "Build the base image for this Java Version")
    }
  agent none
  triggers {
    upstream(upstreamProjects: 'department-of-veterans-affairs/health-apis-spring-boot-application-base/master', threshold: hudson.model.Result.SUCCESS)
  }

  stages {
    /*
    * Make sure we're getting into an infinite loop of build, commit, build because we committed.
    */
    stage('C-C-C-Combo Breaker!') {
      agent {
        dockerfile {
           registryUrl 'https://index.docker.io/v1/'
           registryCredentialsId 'DOCKER_USERNAME_PASSWORD'
           args DOCKER_ARGS
        }
      }
      steps {
        script {
          /*
           * If you need the explanation for this, check out the function. Hard enough to explain once.
           * tl;dr Github web hooks could cause go in an infinite loop.
           */
           env.BUILD_MODE = 'build'
           if (checkBigBen()) {
             env.BUILD_MODE = 'ignore'
             /*
             * OK, this is a janky hack! We don't want this job. We didn't want
             * it to even start building, so we'll make it commit suicide! Build
             * numbers will skip, but whatever, that's better than every other
             * build being cruft.
             */
             currentBuild.result = 'NOT_BUILT'
             currentBuild.rawBuild.delete()
          }
        }
      }
    }
    stage('Build') {
      agent {
        dockerfile {
            registryUrl 'https://index.docker.io/v1/'
            registryCredentialsId 'DOCKER_USERNAME_PASSWORD'
            args DOCKER_ARGS
           }
      }
      steps {
          saunter('./build.sh')
      }
    }
    /*
    I think there should be some kind of notification here.  Ask about Slack Notification fucntion above ^^^
    */
  }
}
