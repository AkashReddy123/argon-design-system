pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = 'dockerhub-credentials'
        IMAGE_NAME = 'balaakashreddyy/argon-web'
        K8S_NAMESPACE = 'default'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/AkashReddy123/argon-design-system.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                        echo "🔨 Building Docker image..."
                        docker build -t ${IMAGE_NAME}:${BUILD_NUMBER} .
                    '''
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIALS}", usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    sh '''
                        echo "📦 Pushing image to DockerHub..."
                        echo $PASS | docker login -u $USER --password-stdin
                        docker push ${IMAGE_NAME}:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    sh '''
                        echo "🚀 Deploying to Kubernetes using mounted kubeconfig..."
                        export KUBECONFIG=/root/.kube/config

                        echo "🔍 Checking cluster access..."
                        kubectl config get-contexts

                        echo "📂 Applying Kubernetes manifests..."
                        kubectl apply -f k8s/ --validate=false --insecure-skip-tls-verify=true

                        echo "✅ Deployment completed successfully!"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo '✅ Deployment successful!'
        }
        failure {
            echo '❌ Pipeline failed!'
        }
    }
}
