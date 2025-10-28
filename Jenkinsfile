pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "balaakashreddyy/argon-design-cicd:${BUILD_NUMBER}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git url: 'https://github.com/AkashReddy123/argon-design-system.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}")
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker push ${DOCKER_IMAGE}
                    """
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh '''
                    export KUBECONFIG=$KUBECONFIG
                    kubectl set image deployment/argon-deployment argon-container=${DOCKER_IMAGE} --record
                    kubectl rollout status deployment/argon-deployment
                    '''
                }
            }
        }
    }
}
