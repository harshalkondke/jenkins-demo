def tomcatServerUrl = "http://172.31.15.38:8080"
pipeline {
  agent {
    node {
      label 'jenkins-slave'
    }
  }

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
          war: '**/*.war',
          contextPath: 'sample'

      }
    }
  }
}
