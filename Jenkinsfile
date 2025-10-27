pipeline 
{
    agent { label 'agent2' }  

    environment {
        NODE_HOME = tool 'node16'  
        ARTIFACT_DIR = 'build'
    }

    stages {

        stage('Install Dependencies') {
            steps {
                sh """
                export PATH=\$NODE_HOME/bin:\$PATH
                npm install
                """
            }
        }

        stage('Build React App') {
            steps {
                sh """
                export PATH=\$NODE_HOME/bin:\$PATH
                npm run build
                """
            }
        }

        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: "${ARTIFACT_DIR}/**", fingerprint: true
            }
        }

        stage('Deploy to Environment') {
            when {
                branch pattern: "dev|qa|prod", comparator: "REGEXP"
            }
            steps {
                script {
                    if (env.BRANCH_NAME == 'dev') {
                        echo "Deploying to DEV environment..."
                        sh """
                        
                        scp -r ${ARTIFACT_DIR}/* ubuntu@dev-server-ip:/var/www/dev-app
                        """
                    } else if (env.BRANCH_NAME == 'qa') {
                        echo "Deploying to QA environment..."
                        sh """
                        scp -r ${ARTIFACT_DIR}/* ubuntu@qa-server-ip:/var/www/qa-app
                        """
                    } else if (env.BRANCH_NAME == 'prod') {
                        echo "Deploying to PROD environment..."
                        sh """
                        scp -r ${ARTIFACT_DIR}/* ubuntu@prod-server-ip:/var/www/prod-app
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Deployment completed successfully for branch: ${env.BRANCH_NAME}"
        }
        failure {
            echo "Deployment failed for branch: ${env.BRANCH_NAME}"
        }
    }
}
