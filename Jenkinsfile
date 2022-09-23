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
// pipeline {
//   agent any 
//     environment {
//         AWS_ACCOUNT_ID="394266983666"
//         AWS_DEFAULT_REGION="ap-south-1" 
//         IMAGE_REPO_NAME="jenkins"
//         IMAGE_TAG="latest"
//         REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
//     }
   
//     stages {
        
//          stage('Logging into AWS ECR') {
//             steps {
//                 script {
//                 sh "/usr/local/bin/aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
//                 }
                 
//             }
//         }
        
   
//     stage('Build with Maven') {
//       steps {
//         checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/harshalkondke/jenkins-demo.git']]])
//         sh 'mvn clean install'
//       }
//     }
//     stage('Build Tomcat Image') {
//       steps {
//         sh 'docker build . -t ${IMAGE_REPO_NAME}:${IMAGE_TAG}' 
//       }
//     }
   
//     // Uploading Docker images into AWS ECR
//     stage('Pushing to ECR') {
//      steps{  
//          script {
//                 sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"
//                 sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
//          }
//         }
//       }

//      stage("Deploy"){
//       steps{
//         sh '/usr/local/bin/kubectl apply -f deployment.yml'
//       }
//     }
//     }
// }

pipeline {
  agent any
  environment {
    AWS_ACCOUNT_ID="394266983666"
    AWS_DEFAULT_REGION="ap-south-1" 
    IMAGE_REPO_NAME="jenkins"
    IMAGE_TAG="latest"
    REPOSITORY_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}"
    ELK_NAMESPACE = "elk-space"
    AWS_EKS_NAME = "eks-ns"
  }
  stages {
    stage('Maven Build') {
      steps {
        checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/harshalkondke/jenkins-demo.git']]])
        sh 'mvn clean install'
      }
    }
    stage('Docker Build') {
      steps {
        sh 'docker build . -t ${IMAGE_REPO_NAME}:${IMAGE_TAG}' 
      }
    }
    stage('Push to ECR') {
      steps {
        script {
          sh "aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com"
          sh "docker tag ${IMAGE_REPO_NAME}:${IMAGE_TAG} ${REPOSITORY_URI}:$IMAGE_TAG"
          sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/${IMAGE_REPO_NAME}:${IMAGE_TAG}"
        }
      }
    }
    stage("Deploy to EKS"){
      steps{
          sh 'kubectl apply -f deployment.yaml'
            }
    }
    stage("Wait for Deployments") {
      steps {
        timeout(time: 2, unit: 'MINUTES') {
          sh 'kubectl get svc'
        }
      }
    }
    stage("get Helm") {
      steps {
        sh '''if helm version
            then
            helm repo list
            else
            curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
            chmod 700 get_helm.sh
            ./get_helm.sh
            helm version
            fi'''
      }
    }
    stage("Add Helm Repo") {
      steps {
        sh '''if helm repo list | grep elastic
            then
            helm repo update
            else
            helm repo add elastic https://charts.helm.sh/stable
            helm repo update
            fi'''
      }
    }
    stage("Install ElasticSearch") {
      steps {
         sh '''if kubectl get ns | grep ${ELK_NAMESPACE}
            then
            kubectl get pods --namespace=${ELK_NAMESPACE} -l app=elasticsearch-master | grep elasticsearch
            else
            kubectl create namespace ${ELK_NAMESPACE}
            helm install elasticsearch elastic/elasticsearch -n ${ELK_NAMESPACE} --set replicas=2
            fi'''
      }
    }
    stage("Install Kibana") {
      steps {
         sh '''if kubectl get pods -n ${ELK_NAMESPACE} | grep kibana
            then
            kubectl get pods -n ${ELK_NAMESPACE} | grep kibana
            else
            helm install kibana elastic/kibana -n ${ELK_NAMESPACE}
            fi'''
      }
    }
    stage("Install Metricbeat") {
      steps {
         sh '''if kubectl get pods -n ${ELK_NAMESPACE} | grep metricbeat
            then
            kubectl get pods -n ${ELK_NAMESPACE} | grep metricbeat
            else
            helm install metricbeat elastic/metricbeat -n ${ELK_NAMESPACE} --set replicas=3
            fi'''
      }
    }
    stage("Get Kibana Dashboard") {
      steps {
         sh '''if kubectl get svc -n ${ELK_NAMESPACE} | grep kibana-dashboard
            then
            kubectl get svc -n ${ELK_NAMESPACE} | grep kibana-dashboard
            else
            kubectl expose deployment kibana --name kibana-dashboard -n ${ELK_NAMESPACE} --type LoadBalancer
            fi'''
      }
      post {
        success{
          sh 'kubectl get svc -n ${ELK_NAMESPACE} | grep kibana-dashboard'
        }
      }
    }
  }
}
