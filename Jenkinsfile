pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "argon-design-system"
        DOCKERHUB_USER = "balaakashreddyy"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/AkashReddy123/argon-design-system.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                bat '''
                echo 🏗️ Building Docker image...
                docker build -t %DOCKER_IMAGE% .
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-login', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    bat '''
                    echo 🔐 Logging into Docker Hub...
                    docker login -u %DOCKER_USER% -p %DOCKER_PASS%
                    docker tag %DOCKER_IMAGE% %DOCKER_USER%/%DOCKER_IMAGE%:latest
                    docker push %DOCKER_USER%/%DOCKER_IMAGE%:latest
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {
                    bat '''
                    set KUBECONFIG=%KUBECONFIG_FILE%
                    echo 🚀 Deploying to Kubernetes...
                    kubectl apply -f k8s/deployment.yaml
                    kubectl apply -f k8s/service.yaml
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline executed successfully!"
        }
        failure {
            echo "❌ Pipeline failed!"
        }
    }
}
