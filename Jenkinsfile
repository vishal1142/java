@Library('jenkinslibrary') _

pipeline {
    agent any

    parameters {
        choice(name: 'action', choices: ['create', 'delete'], description: 'Choose create or delete')
        string(name: 'ImageName', description: "Name of the Docker image", defaultValue: 'javapp')
        string(name: 'ImageTag', description: "Tag of the Docker image", defaultValue: 'v1')
        string(name: 'DockerHubUser', description: "DockerHub username", defaultValue: 'awsdevops12345')
        string(name: 'DockerHubCredId', description: "Jenkins credentials ID for DockerHub", defaultValue: 'vishal')
    }

    stages {
        stage('Git Checkout') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Checking out source code...'
                    checkoutGit('https://github.com/vishal1142/java.git', 'main')
                }
            }
        }

        stage('Tests & Code Quality') {
            when { expression { params.action == 'create' } }
            parallel {
                stage('Unit Test') {
                    steps {
                        script {
                            echo 'Running unit tests...'
                            runTests('unit')
                        }
                    }
                }
                stage('Integration Test') {
                    steps {
                        script {
                            echo 'Running integration tests...'
                            runTests('integration')
                        }
                    }
                }
                stage('Static Code Analysis (SonarQube)') {
                    steps {
                        script {
                            echo 'Performing static code analysis with SonarQube...'
                            performSonarQubeAnalysis()
                        }
                    }
                }
            }
        }

        stage('Quality Gate Check') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Checking SonarQube Quality Gate status...'
                    checkQualityGate()
                }
            }
        }

        stage('Build') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Building the project...'
                    buildProject()
                }
            }
        }

        stage('Docker Image Build') {
            when { expression { params.action == 'create' } }
            steps {
                script {
                    echo 'Building Docker image...'
                    buildDockerImage()
                }
            }
        }
    }

    post {
        always {
            echo 'This will always run, regardless of success or failure.'
        }
        success {
            echo 'Pipeline succeeded!'
        }
        failure {
            echo 'Pipeline failed.'
        }
    }
}

def checkoutGit(repoUrl, branch) {
    try {
        git url: repoUrl, branch: branch
    } catch (Exception e) {
        echo "Git checkout failed: ${e.message}"
        currentBuild.result = 'FAILURE'
        throw e
    }
}

def runTests(testType) {
    try {
        if (testType == 'unit') {
            mvnTest()
        } else if (testType == 'integration') {
            mvnIntegrationTest()
        }
    } catch (Exception e) {
        echo "${testType.capitalize()} test failed: ${e.message}"
        currentBuild.result = 'FAILURE'
        throw e
    }
}

def performSonarQubeAnalysis() {
    try {
        staticCodeAnalysis(
            credentialsId: 'sonarqube-api',
            sonarHostUrl: 'http://192.168.1.141:9000',
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

def checkQualityGate() {
    try {
        QualityGateStatus(credentialsId: 'sonarqube-api')
    } catch (Exception e) {
        echo "Quality Gate check failed: ${e.message}"
        currentBuild.result = 'FAILURE'
        throw e
    }
}

def buildProject() {
    try {
        mvnBuild()
    } catch (Exception e) {
        echo "Build failed: ${e.message}"
        currentBuild.result = 'FAILURE'
        throw e
    }
}

def buildDockerImage() {
    try {
        // Instantiate DockerHelper from shared library
        def docker = new org.mytools.DockerHelper(this)

        // Call the performDockerOperations method
        docker.performDockerOperations(
            params.ImageName,
            params.ImageTag,
            params.DockerHubUser,
            params.DockerHubCredId
        )
    } catch (Exception e) {
        echo "Docker operation failed: ${e.message}"
        currentBuild.result = 'FAILURE'
        throw e
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
