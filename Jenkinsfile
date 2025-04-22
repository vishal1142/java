@Library('jenkinslibrary') _

pipeline {

    agent any

    parameters{

        choice(name: 'action', choices: 'create\ndelete', description: 'Choose create/Destroy')
    }    

    stages {

        when { expression {  params.action == 'create' } }

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

        stage('Unit Test Maven') {
            steps {
            
            when { expression {  params.action == 'create' } }

                script {
                    echo 'Running unit tests...'
                    mvnTest()
                }
            }
        }

        stage('Integration Test Maven') {
            steps {
                when { expression {  params.action == 'create' } }
                
                script {
                    echo 'Running integration tests...'
                    mvnIntegrationTest()
                }
            }
        }

        stage('Static code analysis: SonarQube') {
            steps {

                when { expression {  params.action == 'create' } }
                 
                script {
                    echo 'statiCodeAnalysis..'
                    statiCodeAnalysis()
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
