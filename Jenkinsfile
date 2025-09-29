pipeline {
  agent any
  environment {
    IMAGE_NAME = "myusername/minikube-web"
    IMAGE_TAG  = "v${env.BUILD_NUMBER}"
    USE_MINIKUBE_DOCKER = "${env.USE_MINIKUBE_DOCKER ?: 'false'}" // set true to build inside minikube
    KUBE_NAMESPACE = "webapp-ns"
  }
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Build Docker Image') {
      steps {
        script {
          if (env.USE_MINIKUBE_DOCKER == 'true') {
            sh 'eval $(minikube docker-env)'
            sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
          } else {
            sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
          }
        }
      }
    }
    stage('Push Image') {
      when {
        expression { env.USE_MINIKUBE_DOCKER == 'false' }
      }
      steps {
        withCredentials([usernamePassword(credentialsId: 'docker-hub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
          sh "docker push ${IMAGE_NAME}:${IMAGE_TAG}"
        }
      }
    }
    stage('Deploy to Kubernetes') {
      steps {
        // update k8s deployment image then rollout
        withCredentials([file(credentialsId: 'kubeconfig-file', variable: 'KUBECONFIG')]) {
          sh 'export KUBECONFIG=$KUBECONFIG'
          // If using Terraform
          // sh 'cd terraform && terraform init && terraform apply -var="image=${IMAGE_NAME}:${IMAGE_TAG}" -auto-approve'
          // or patch deployment directly:
          sh "kubectl -n ${KUBE_NAMESPACE} set image deployment/web-deploy web=${IMAGE_NAME}:${IMAGE_TAG} || kubectl -n ${KUBE_NAMESPACE} apply -f k8s/deployment.yaml"
          sh "kubectl -n ${KUBE_NAMESPACE} rollout status deployment/web-deploy --timeout=120s"
        }
      }
    }
  }
  post {
    success { echo "Deployed ${IMAGE_NAME}:${IMAGE_TAG}" }
    failure { echo "Build/Deploy failed" }
  }
}

