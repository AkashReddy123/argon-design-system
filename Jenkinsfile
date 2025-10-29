pipeline {
  agent any

  environment {
    DOCKER_CRED = 'docker-hub'                      // Jenkins credential ID
    IMAGE_NAME = "balaakashreddyy/argon-design-system"
    K8S_MANIFEST = "deployment.yaml"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build (npm/gulp if present)') {
      steps {
        script {
          if (fileExists('package.json')) {
            sh 'npm ci || true'
            if (fileExists('gulpfile.js')) {
              sh 'npx gulp || true'
            } else {
              // run npm build if exists
              sh 'if npm run | grep -q \" build\"; then npm run build || true; fi'
            }
          } else {
            echo 'No package.json — skipping build step.'
          }
        }
      }
    }

    stage('Docker Build') {
      steps {
        script {
          GIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
          sh "docker build -t ${IMAGE_NAME}:${GIT_SHORT} -t ${IMAGE_NAME}:latest ."
        }
      }
    }

    stage('Docker Login & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKER_CRED, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
          script {
            GIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
            sh "docker push ${IMAGE_NAME}:${GIT_SHORT}"
            sh "docker push ${IMAGE_NAME}:latest"
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        script {
          if (!fileExists(env.K8S_MANIFEST)) {
            error "Kubernetes manifest not found at ${env.K8S_MANIFEST}"
          }

          // replace placeholder with image tag
          GIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
          sh "sed -i 's|__IMAGE_PLACEHOLDER__|${IMAGE_NAME}:${GIT_SHORT}|g' ${env.K8S_MANIFEST} || true"

          // run kubectl inside a container, using host kubeconfig mounted into Jenkins container at /root/.kube
          sh """
            docker run --rm \
              -v /root/.kube:/root/.kube:ro \
              -v \$(pwd):/workdir \
              bitnami/kubectl:latest apply -f /workdir/${env.K8S_MANIFEST}
          """

          // show services
          sh "docker run --rm -v /root/.kube:/root/.kube:ro bitnami/kubectl:latest -n default get svc"
        }
      }
    }
  } // stages

  post {
    success { echo "Pipeline succeeded." }
    failure { echo "Pipeline failed." }
    always { echo "Pipeline finished." }
  }
}
