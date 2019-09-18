def saunter(scriptName) {
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
    usernamePassword(
      credentialsId: 'QUALYS_USERNAME_PASSWORD',
      usernameVariable: 'QUALYS_USERNAME',
      passwordVariable: 'QUALYS_PASSWORD')
  ]) {
    echo "APPLICATION_BASE_VERSION = ${env.APPLICATION_BASE_VERSION}"
    sh script: scriptName
  }
}

def sendDeployMessage(channelName) {
  slackSend(
    channel: channelName,
    color: '#4682B4',
    message: "Building spring-boot-application-base ${env.APPLICATION_BASE_VERSION} - ${env.JOB_NAME} ${env.BUILD_NUMBER}"
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
    choice(name: 'APPLICATION_BASE_VERSION', choices: ['none','8','12'], description: "Build the base image for this Java Version")
    }
  agent {
      dockerfile {
        registryUrl 'https://index.docker.io/v1/'
        registryCredentialsId 'DOCKER_USERNAME_PASSWORD'
      args "--entrypoint='' --privileged --group-add 497 -v /etc/passwd:/etc/passwd:ro -v /etc/group:/etc/group:ro -v /data/jenkins/.m2/repository:/home/jenkins/.m2/repository -v /var/lib/jenkins/.ssh:/home/jenkins/.ssh -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker:/var/lib/docker"
    }
  }
  triggers {
    upstream(upstreamProjects: 'department-of-veterans-affairs/health-apis-spring-boot-application-base/master', threshold: hudson.model.Result.SUCCESS)
  }
  stages {
    /*
    * Make sure we're getting into an infinite loop of build, commit, build because we committed.
    */
    stage('C-C-C-Combo Breaker!') {
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
      when {
        expression { return env.BUILD_MODE != 'ignore' }
        /*
        expression { return env.BRANCH_NAME == 'master' }
        */
      }
      steps {
        saunter('./build.sh')
      }
    }
    /*
    I think there should be some kind of notification here.  Ask about Slack Notification function above ^^^
    */
  }
}
