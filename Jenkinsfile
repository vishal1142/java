@Library('jenkinslibrary') _

pipeline {
    agent any

    stages {
        stage('Git Checkout') {
            steps {
                script {
                    gitCheckout(
                        branch: 'main',
                        url: 'https://github.com/vishal1142/java.git'
                    )
                }
            }
        }

        stage('Run Maven Tests') {
            steps {
                script {
                    mvnTest() // This will call your defined method: def call() { sh 'mvn test' }
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
