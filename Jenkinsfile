def tomcatServerUrl = "http://172.31.15.38:8080"
pipeline {
  agent {
    node {
      label 'jenkins-slave'
    }
  }

  stages {
    stage('SonarQube') {
        steps{
          withSonarQubeEnv('sonarqube-8.7') { 
            sh "mvn sonar:sonar"
          }
        }
    }
    stage('Build') {
      steps {
        // Run the maven build
        sh '"mvn" -Dmaven.test.failure.ignore clean install'
      }

    }
   
    stage('Test') {
      steps {
        sh(script: 'mvn --batch-mode -Dmaven.test.failure.ignore=true test')

      }
    }
    stage('Deploy') {
      steps {
        //deploy war on tomcat server
        deploy adapters: [tomcat8(url: "${tomcatServerUrl}",
            credentialsId: 'tomcat-cred')],
          war: '**/*.war',
          contextPath: 'sample'

      }
    }
  }
}
