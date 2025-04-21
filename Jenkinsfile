@Library('jenkinslibrary') _

pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/vishal1142/java.git'
        GIT_BRANCH = 'main'
        JAVA_HOME = '/usr/lib/jvm/java-11-openjdk-amd64'
        PATH = "${JAVA_HOME}/bin:${env.PATH}"
    }

    stages {
        stage('Git Checkout') {
            steps {
                script {
                    gitCheckout(
                        branch: "${GIT_BRANCH}",
                        url: "${GIT_REPO}"
                    )
                }
            }
        }

        stage('Verify Java Setup') {
            steps {
                sh '''
                    echo "JAVA_HOME: $JAVA_HOME"
                    echo "PATH: $PATH"
                    which java
                    java -version
                '''
            }
        }

        stage('Run Maven Tests') {
            steps {
                script {
                    try {
                        // Use shared library or raw Maven command
                        sh 'mvn test'
                    } catch (Exception e) {
                        echo "Maven test stage failed: ${e.getMessage()}"
                        throw e
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'This will always run'
        }
        success {
            echo 'This will run only if the pipeline is successful'
        }
        failure {
            echo 'This will run only if the pipeline fails'
        }
    }
}
