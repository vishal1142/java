 @Library('jenkinslibrary') _

pipeline {
    agent any

    parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create or delete')
        string(name: 'ImageName', description: "Name of the Docker image", defaultValue: 'javapp')
        string(name: 'ImageTag', description: "Tag of the Docker image", defaultValue: 'v1')
        string(name: 'DockerHubUser', description: "DockerHub username", defaultValue: 'awsdevops12345')
    }

    stages {
        stage('Git Checkout') {
            when { expression { params.action == 'create' } }
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
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Running unit tests...'
                    mvnTest()
                }
            }
        }

        stage('Integration Test') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Running integration tests...'
                    mvnIntegrationTest()
                }
            }
        }

        stage('Static Code Analysis (SonarQube)') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Performing static code analysis with SonarQube...'
                    staticCodeAnalysis(
                        credentialsId: 'sonarqube-api',
                        sonarHostUrl: 'http://192.168.1.186:9000',
                        sonarProjectKey: 'java-jenkins-demo',
                        sonarProjectName: 'Java Jenkins Demo',
                        sonarProjectVersion: '1.0'
                    )
                }
            }
        }

        stage('Quality Gate Check') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Checking SonarQube Quality Gate status...'
                    QualityGateStatus(credentialsId: 'sonarqube-api')
                }
            }
        }

        stage('Build') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Building the project...'
                    mvnBuild()
                }
            }
        }

        stage('Docker Image Build') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Building the Docker image...'
                    dockerBuild(
                        params.ImageName,
                        params.ImageTag,
                        params.DockerHubUser
                    )
                }
            }
        }

    //    stage('Cleanup') {
    //        when { expression { params.action == 'delete' } }
    //        steps {
    //            script {
    //                echo 'Cleaning up resources...'
    //                cleanupResources()
    //            }
    //        }
    //    }
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
