@Library('jenkinslibrary') _

pipeline {
    agent {
        docker {
            image 'maven:3.9.6-eclipse-temurin-17' // Use Maven with JDK 17
            args '-v $HOME/.m2:/root/.m2' // Optional: Cache dependencies between builds
        }
    }

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
            echo '✅ This will always run'
        }
        success {
            echo '🎉 Build & Tests Successful'
        }
        failure {
            echo '❌ Build or Tests Failed'
        }
    }
}
