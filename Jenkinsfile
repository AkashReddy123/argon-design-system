pipeline {
  agent any

  environment {
    IMAGE_NAME = "balaakashreddyy/new"
    DOCKER_CRED = "docker-hub"
    KUBECONFIG_CRED = "kubeconfig"
    K8S_MANIFEST = "k8s/deployment.yaml"
    WORKDIR = "${env.WORKSPACE}"
  }

  options {
    timeout(time: 30, unit: 'MINUTES')
    buildDiscarder(logRotator(numToKeepStr: '10'))
    ansiColor('xterm')
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Prepare / Build (optional)') {
      steps {
        script {
          if (fileExists('package.json')) {
            sh 'npm ci || true'
            if (fileExists('gulpfile.js')) {
              sh 'npx gulp || true'
            } else {
              sh 'if npm run | grep -q " build" ; then npm run build || true; fi'
            }
          } else {
            echo 'No package.json found — skipping Node/gulp build.'
          }
        }
      }
    }

    stage('Docker Build') {
      steps {
        script {
          def tag = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
          sh "docker build -t ${IMAGE_NAME}:${tag} -t ${IMAGE_NAME}:latest ."
        }
      }
    }

    stage('Docker Login & Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: env.DOCKER_CRED, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
          script {
            def tag = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
            sh "docker push ${IMAGE_NAME}:${tag}"
            sh "docker push ${IMAGE_NAME}:latest || true"
          }
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        script {
          if (!fileExists(env.K8S_MANIFEST)) {
            error "K8S manifest not found at ${env.K8S_MANIFEST}"
          }
          def tag = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
          // Replace placeholder in a temp copy so original file stays
          sh "cp ${env.K8S_MANIFEST} ${env.K8S_MANIFEST}.ci"
          sh "sed -i 's|__IMAGE_PLACEHOLDER__|${IMAGE_NAME}:${tag}|g' ${env.K8S_MANIFEST}.ci"

          // Debugging
          sh 'ls -lh k8s/'
          sh "cat ${env.K8S_MANIFEST}.ci"

          withCredentials([file(credentialsId: env.KUBECONFIG_CRED, variable: 'KCFG')]) {
            sh """
              mkdir -p \$WORKSPACE/.kube
              cp \$KCFG \$WORKSPACE/.kube/config
              chmod 600 \$WORKSPACE/.kube/config

              docker run --rm \
                -v \$WORKSPACE:/workdir \
                -v \$WORKSPACE/.kube:/root/.kube:ro \
                bitnami/kubectl:latest apply -f /workdir/${env.K8S_MANIFEST}.ci

              docker run --rm \
                -v \$WORKSPACE/.kube:/root/.kube:ro \
                bitnami/kubectl:latest -n default get svc || true
            """
          }
        }
      }
    }
  } // stages

  post {
    success {
      echo "SUCCESS: ${IMAGE_NAME} built, pushed and deployed."
    }
    failure {
      echo "FAILURE: check logs above."
    }
    always {
      cleanWs()
    }
  }
}
