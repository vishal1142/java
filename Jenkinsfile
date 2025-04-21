@Library('jenkinslibrary') _

pipeline {
    agent {
        docker {
            image 'maven:3.9.6-eclipse-temurin-17'
            args '-v $HOME/.m2:/root/.m2' // Cache Maven dependencies between builds
        }
    }

    environment {
        GIT_REPO   = 'https://github.com/vishal1142/java.git'
        GIT_BRANCH = 'main'
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    gitCheckout(
                        branch: GIT_BRANCH,
                        url: GIT_REPO
                    )
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                script {
                    mvnTest() // Defined in your Jenkins shared library
                }
            }
        }
    }

    post {
        always {
            echo '✅ Always executed post-build step'
        }
        success {
            echo '🎉 Build and Tests Passed Successfully'
        }
        failure {
            echo '❌ Build or Tests Failed'
        }
    }
}
