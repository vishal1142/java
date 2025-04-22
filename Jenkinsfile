@Library('jenkinslibrary') _

pipeline {
    agent any

    parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create or delete')
    }

    stages {
        stage('Git Checkout') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                script {
                    echo 'Checking out source code...'
                    gitCheckout(
                        branch: 'main',
                        url: 'https://github.com/vishal1142/java.git'
                    )
                }
            }
        }

        stage('Unit Test') {
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

        stage('Integration Test') {
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

        stage('Static Code Analysis (SonarQube)') {
            when {
                expression { params.action == 'create' }
            }
            steps {
                script {
                    echo 'Performing static code analysis with SonarQube...'
                    // Call the shared library method for SonarQube static code analysis
                    staticCodeAnalysis(
                        credentialsId: 'sonarqube-api', // Jenkins credentials ID for SonarQube
                        sonarHostUrl: 'http://localhost:9000', // SonarQube host URL
                        sonarProjectKey: 'java-jenkins-demo', // SonarQube project key
                        sonarProjectName: 'Java Jenkins Demo', // SonarQube project name
                        sonarProjectVersion: '1.0' // SonarQube project version
                    )
                }
            }
        }
    }

    post {
        always {
            echo 'This will always run'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}
