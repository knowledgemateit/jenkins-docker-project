pipeline {
    agent any
    
    environment {
        DOCKER_HUB_REPO = 'rajusw804/testproject'
        DOCKER_HUB_CREDS = credentials('docker-hub-credentials')
        VERSION         = "1.0.${BUILD_NUMBER}"
        IMAGE_NAME      = "${DOCKER_HUB_REPO}:${VERSION}"
        // Unique container name to avoid conflicts during parallel builds
        CONTAINER_NAME  = "tomcat-test-${BUILD_NUMBER}" 
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Maven Artifact') {
            steps {
                // Generate the .war file needed by the Dockerfile
                sh 'mvn clean package -DskipTests'
                
                // Safety check: Ensure the war file was actually created
                sh 'ls -l target/*.war'
            }
        }

        stage('Docker Build') {
            steps {
                echo "Building Docker Image: ${IMAGE_NAME}"
                // Build with both the specific version and 'latest' tag
                sh "docker build -t ${IMAGE_NAME} -t ${DOCKER_HUB_REPO}:latest ."
            }
        }

        stage('Smoke Test (Verify Tomcat)') {
            steps {
                script {
                    echo "Starting container to verify deployment..."
                    // Run detached on port 8091
                    sh "docker run -d --name ${CONTAINER_NAME} -p 8091:8080 ${IMAGE_NAME}"
                    
                    // Give Tomcat a moment to deploy the WAR file
                    echo "Waiting 15 seconds for Tomcat to initialize..."
                    sleep 15
                    
                    // Check if the server responds. 
                    // Note: You might need to adjust the URL path if your app has a context root
                    sh "curl -f http://localhost:8091 || (docker logs ${CONTAINER_NAME} && exit 1)"
                    
                    echo "Verification Passed!"
                }
            }
            post {
                always {
                    // Always remove the test container so port 8091 is freed up
                    sh "docker rm -f ${CONTAINER_NAME} || true"
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    sh "echo ${DOCKER_HUB_CREDS_PSW} | docker login -u ${DOCKER_HUB_CREDS_USR} --password-stdin"
                    sh "docker push ${IMAGE_NAME}"
                    sh "docker push ${DOCKER_HUB_REPO}:latest"
                }
            }
        }
    }

    post {
        always {
            sh "docker logout"
        }
        cleanup {
            // Remove local images to prevent Jenkins disk space from filling up
            sh "docker rmi ${IMAGE_NAME} ${DOCKER_HUB_REPO}:latest || true"
            echo "Local cleanup complete."
        }
    }
}
