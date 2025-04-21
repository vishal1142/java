pipeline {
    agent any

    environment {
        JAVA_HOME = '/usr/lib/jvm/java-11-openjdk-amd64'  // JDK path
        MAVEN_HOME = '/usr/share/maven'                   // Maven path
        PATH = "${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${env.PATH}"  // Update PATH with Java and Maven
    }

    stages {
        stage('Checkout Code') {
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
                    try {
                        sh 'mvn test'  // Run tests with Maven
                    } catch (Exception e) {
                        echo "Test execution failed: ${e.getMessage()}"
                        throw e  // Fail the pipeline if Maven tests fail
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                echo 'Cleanup or final tasks can be added here.'
            }
        }
        success {
            script {
                echo 'Tests passed successfully, proceeding to the next stage.'
            }
        }
        failure {
            script {
                echo 'Tests failed, please review the error logs.'
            }
        }
    }
}
