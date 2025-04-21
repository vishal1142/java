pipeline {
    agent any

    environment {
        JAVA_HOME = '/usr/lib/jvm/java-11-openjdk-amd64'  // Path to your JDK installation
        MAVEN_HOME = '/usr/share/maven'                   // Path to your Maven installation
        PATH = "${JAVA_HOME}/bin:${MAVEN_HOME}/bin:${env.PATH}"  // Add Java and Maven to PATH
    }

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
                    try {
                        sh 'mvn test'  // Run Maven test after setting JAVA_HOME and MAVEN_HOME
                    } catch (Exception e) {
                        echo "Maven test stage failed: ${e.getMessage()}"
                        throw e  // Fail the pipeline if Maven test fails
                    }
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
