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
                    try {
                        gitCheckout(
                            branch: 'main',
                            url: 'https://github.com/vishal1142/java.git'
                        )
                    } catch (Exception e) {
                        echo "Git checkout failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }

        stage('Unit Test') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Running unit tests...'
                    try {
                        mvnTest()
                    } catch (Exception e) {
                        echo "Unit test failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }

        stage('Integration Test') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Running integration tests...'
                    try {
                        mvnIntegrationTest()
                    } catch (Exception e) {
                        echo "Integration test failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }

        stage('Static Code Analysis (SonarQube)') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Performing static code analysis with SonarQube...'
                    try {
                        staticCodeAnalysis(
                            credentialsId: 'sonarqube-api',
                            sonarHostUrl: 'http://192.168.1.186:9000',
                            sonarProjectKey: 'java-jenkins-demo',
                            sonarProjectName: 'Java Jenkins Demo',
                            sonarProjectVersion: '1.0'
                        )
                    } catch (Exception e) {
                        echo "SonarQube analysis failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }

        stage('Quality Gate Check') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Checking SonarQube Quality Gate status...'
                    try {
                        QualityGateStatus(credentialsId: 'sonarqube-api')
                    } catch (Exception e) {
                        echo "Quality Gate check failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }

        stage('Build') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Building the project...'
                    try {
                        mvnBuild()
                    } catch (Exception e) {
                        echo "Build failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
                        throw e
                    }
                }
            }
        }

        stage('Docker Image Build') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Building the Docker image...'
                    try {
                        dockerBuild(
                            params.ImageName,
                            params.ImageTag,
                            params.DockerHubUser
                        )
                    } catch (Exception e) {
                        echo "Docker build failed: ${e.message}"
                        currentBuild.result = 'FAILURE'
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
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed.'
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
