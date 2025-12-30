pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'projectimage:1.0.0'
        DOCKER_HUB_REPO = 'rajusw804/testproject'
        DOCKER_HUB_CREDS = credentials('docker-hub-credentials') // Create these in Jenkins
        VERSION = "1.0.${BUILD_NUMBER}"
        CONTAINER_NAME = 'projectcontainer'
    }

    stages {
        stage('Initialize') {
            steps {
                // Ensuring Docker socket is accessible if needed, though 
                // typically handled by adding the 'jenkins' user to the 'docker' group
                sh 'sudo chmod 666 /var/run/docker.sock || true'
            }
        }

        stage('Build Artifact') {
            steps {
                sh 'mvn clean package'
            }
        }

        stage('Cleanup Environment') {
            steps {
                script {
                    sh "docker rm -f ${CONTAINER_NAME} || true"
                    sh "docker rmi -f ${DOCKER_IMAGE} || true"
                }
            }
        }

        stage('Docker Build & Run') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
                // Running detached to allow the commit step to capture the state
                sh "docker run -d --name ${CONTAINER_NAME} -p 8091:8080 ${DOCKER_IMAGE}"
            }
        }

        stage('Docker Commit & Push') {
            steps {
                script {
                    // Login using environment variables from credentials
                    sh "echo ${DOCKER_HUB_CREDS_PSW} | docker login -u ${DOCKER_HUB_CREDS_USR} --password-stdin"
                    
                    // Commit the running container to a new image tag
                    sh "docker commit ${CONTAINER_NAME} ${DOCKER_HUB_REPO}:${VERSION}"
                    
                    // Push the committed image
                    sh "docker push ${DOCKER_HUB_REPO}:${VERSION}"
                }
            }
        }
    }

    post {
        always {
            sh "docker stop ${CONTAINER_NAME} || true"
            sh "docker logout"
        }
    }
}
