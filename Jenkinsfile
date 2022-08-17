def tomcatServerUrl = "http://172.31.12.179:8080"
pipeline {
  agent {
    node {
      label 'jenkins-slave'
    }
  }

  stages {
    //Use this code for inline pipeline script option
    /* stage('Code checkout') {
      steps {
        //download code from github
        git 'https://github.com/ajitinamdar-tech/jenkins-cicd-java-maven-demo.git'
      }
    }*/
    stage('Build') {
      steps {
        // Run the maven build
        sh '"mvn" -Dmaven.test.failure.ignore clean install'
      }

    }
    stage('Deploy') {
      steps {
        //deploy war on tomcat server
        deploy adapters: [tomcat8(url: "${tomcatServerUrl}",
            credentialsId: 'tomcat-cred')],
          war: 'target/*.war',
          contextPath: 'pipeline-app'

      }
    }
  }
}
