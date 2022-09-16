// def tomcatServerUrl = "http://172.31.15.38:8080"
// pipeline {
//   agent {
//     node {
//       label 'jenkins-slave'
//     }
//   }

//   stages {
//     stage('Build') {
//       steps {
//         // Run the maven build
//         sh '"mvn" -Dmaven.test.failure.ignore clean install'
//       }

//     }
//     stage('SonarQube analysis') {
//         steps{
//           withSonarQubeEnv('sonarqube-8.7') { 
//             sh "mvn sonar:sonar"
//           }
//         }
//     }
//     stage('Deploy') {
//       steps {
//         //deploy war on tomcat server
//         deploy adapters: [tomcat8(url: "${tomcatServerUrl}",
//             credentialsId: 'tomcat-cred')],
//           war: '**/*.war',
//           contextPath: 'sample'

//       }
//     }
//   }
// }
pipeline {
  agent any 
//   tools { maven 'maven-3.6.3' }
    environment {
        AWS_ACCOUNT_ID="394266983666"
        AWS_DEFAULT_REGION="ap-south-1" 
        IMAGE_REPO_NAME="jenkins"
        IMAGE_TAG="latest"
        REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    }
   
    stages {
        
         stage('Logging into AWS ECR') {
            steps {
                script {
                sh "/usr/local/bin/aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
                }
                 
            }
        }
        
        stage('Cloning Git') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '', url: 'https://github.com/harshalkondke/jenkins-demo.git']]])     
            }
        }
      stage('Build') {
          steps {
            // Run the maven build
              sh 'mvn clean install'
          }
    }
  
    // Building Docker images
    stage('Building image') {
      steps {
        sh 'docker build . -t ${IMAGE_REPO_NAME}:${IMAGE_TAG}' 
      }
    }
   
    // Uploading Docker images into AWS ECR
    stage('Pushing to ECR') {
     steps{  
         script {
                sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"
                sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
         }
        }
      }

     stage("Deploy"){
      steps{
        
        withCredentials([string(credentialsId: 'kubes', variable: 'kubes')]){
             sh 'kubectl apply -f <diretory-or-file> --token kubes --server apiserver.hostname.local' }
//           sh 'kubectl apply -f deployment.yml'
//         withCredentials([string(credentialsId: 'kubes', variable: 'kubes')]){
//           //sh '/usr/local/bin/aws eks update-kubeconfig --name demo-eks --region ap-south-1'
//           sh 'kubectl apply -f deployment.yml --context demo-eks'
// //           sh '''if /usr/local/bin/kubectl get deploy | grep java-login-app
// //           then
// //           /usr/local/bin/kubectl set image deployment java-login-app=394266983666.dkr.ecr.ap-south-1.amazonaws.com/jenkins:latest
// //           /usr/local/bin/kubectl rollout restart deployment java-login-app
// //           else
// //           /usr/local/bin/kubectl apply -f deployment.yml
// //           fi'''
//         }
      }
    }

    }
}
