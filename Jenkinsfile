pipeline {
    agent { label 'agent2' }

    environment {
        ARTIFACT_DIR = 'build'
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        IMAGE_NAME = 'gayatri491/react-app'
        BRANCH_TAG = "${env.BRANCH_NAME}"
    }

    stages {
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }

        stage('Build React App') {
            steps {
                sh "npm run build"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${BRANCH_TAG} ."
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push ${IMAGE_NAME}:${BRANCH_TAG}
                    """
                }
            }
        }

        stage('Deploy to Environment') {
            when {
                branch pattern: "dev|qa|prod", comparator: "REGEXP"
            }
            steps {
                script {
                    def server_ip = ""
                    if (env.BRANCH_NAME == 'dev') {
                        server_ip = env.dev_ip
                    } else if (env.BRANCH_NAME == 'qa') {
                        server_ip = env.qa_ip
                    } else if (env.BRANCH_NAME == 'prod') {
                        server_ip = env.prod_ip
                    }

                    sh """
                    ssh -i key123.pem ubuntu@${server_ip} '
                        docker pull ${IMAGE_NAME}:${BRANCH_TAG}
                        docker stop react-app || true
                        docker rm react-app || true
                        docker run -d -p 80:80 --name react-app ${IMAGE_NAME}:${BRANCH_TAG}
                    '
                    """
                }
            }
        }
    }
}
