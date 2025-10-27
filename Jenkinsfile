pipeline {
    agent { label 'agent2' }

    environment {
        ARTIFACT_DIR = 'build'
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
                sh "CI=false npm run build"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${BRANCH_TAG} ."
                }
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: "${ARTIFACT_DIR}/**", fingerprint: true
            }
        }

        stage('Push Docker Image') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DOCKERHUB_CREDENTIALS', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
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
                    def SERVER_IP = ""

                    withCredentials([string(credentialsId: 'dev_ip', variable: 'DEV_IP'),
                                     string(credentialsId: 'qa_ip', variable: 'QA_IP'),
                                     string(credentialsId: 'prod-ip', variable: 'PROD_IP')]) {
                                     usernamePassword(credentialsId: 'DOCKERHUB_CREDENTIALS', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')
                        if (env.BRANCH_NAME == 'dev') {
                            SERVER_IP = DEV_IP
                        } else if (env.BRANCH_NAME == 'qa') {
                            SERVER_IP = QA_IP
                        } else if (env.BRANCH_NAME == 'prod') {
                            SERVER_IP = PROD_IP
                        }
                    }

                    sh """
                    ssh -i ~/.ssh/key123.pem ubuntu@${SERVER_IP} "
                        docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}
                        docker pull ${IMAGE_NAME}:${env.BRANCH_NAME}
                        docker stop react-app || true
                        docker rm react-app || true
                        docker run -d -p 80:80 --name react-app ${IMAGE_NAME}:${env.BRANCH_NAME}
                    "
                    """
                }
            }
        }
    
    }
}
