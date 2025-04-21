@Library('jenkinslibrary') _

pipeline {
    agent any

    environment {
        GIT_REPO = 'https://github.com/vishal1142/java.git'
        GIT_BRANCH = 'main'
        JAVA_HOME = '/usr/lib/jvm/java-11-openjdk-amd64'
    }

    stages {
        stage('Git Checkout') {
            steps {
                script {
                    gitCheckout(
                        branch: "${GIT_BRANCH}",
                        url: "${GIT_REPO}"
                    )
                }
            }
        }

        stage('Verify Java Setup') {
            steps {
                sh '''
                    echo "Verifying JAVA_HOME and java version..."
                    export JAVA_HOME=${JAVA_HOME}
                    export PATH=$JAVA_HOME/bin:$PATH
                    echo "JAVA_HOME is: $JAVA_HOME"
                    which java
                    java -version
                '''
            }
        }

        stage('Run Maven Tests') {
    steps {
        script {
            try {
                sh '''
                    export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
                    export PATH=$JAVA_HOME/bin:$PATH
                    echo "Using java at: $(which java)"
                    java -version
                    /usr/bin/mvn test
                '''
            } catch (Exception e) {
                echo "Maven test stage failed: ${e.getMessage()}"
                throw e
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
