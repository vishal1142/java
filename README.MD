Access the Jenkins container:
docker exec -u root -it <jenkins-container-id> bash
apt-get update
apt-get install -y docker.io
service docker start
apt-get update
apt-get install -y maven
mvn -v
apt-get update && apt-get install -y openjdk-11-jdk
apt-get install -y default-jdk
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH
echo $JAVA_HOME
sonartoken:squ_b0ea5d224d097948ec7a2506531a616d066febb4