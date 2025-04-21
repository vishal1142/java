@Library('jenkinslibrary') _

pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/vishal1142/java.git'
        GIT_BRANCH = 'main'
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
                    mvnTest() // Calls shared library step that runs `mvn test`
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
