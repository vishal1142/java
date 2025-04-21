@Library('jenkinslibrary') _

pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/vishal1142/java.git'
        GIT_BRANCH = 'main'
        JAVA_HOME = '/usr/lib/jvm/java-11-openjdk-amd64'  // Set the correct Java home path
        PATH = "${JAVA_HOME}/bin:${env.PATH}"  // Ensure Java binaries are in the PATH
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

        stage('Run Maven Tests') {
            steps {
                script {
                    try {
                        sh 'mvn test'  // Run Maven tests directly
                    } catch (Exception e) {
                        echo "Maven test stage failed: ${e.getMessage()}"
                        throw e  // Fail the pipeline on error
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                echo 'This will always run'
            }
        }
        success {
            script {
                echo 'This will run only if the pipeline is successful'
            }
        }
        failure {
            script {
                echo 'This will run only if the pipeline fails'
            }
        }
    }
}
