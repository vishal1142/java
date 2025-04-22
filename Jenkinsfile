@Library('jenkinslibrary') _

pipeline {
    agent any

    parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create/Destroy')
    }

    stages {
        stage('Git Checkout') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                script {
                    gitCheckout(
                        branch: 'main',
                        url: 'https://github.com/vishal1142/java.git'
                    )
                }
            }
        }

        stage('Unit Test Maven') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                script {
                    echo 'Running unit tests...'
                    mvnTest()
                }
            }
        }

        stage('Integration Test Maven') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                script {
                    echo 'Running integration tests...'
                    mvnIntegrationTest()
                }
            }
        }

        stage('Static code analysis: SonarQube') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                script {
                    echo 'Static Code Analysis...'
                    statiCodeAnalysis()
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
