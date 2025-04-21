Access the Jenkins container:
docker exec -u root -it <jenkins-container-id> bash
apt-get update
apt-get install -y docker.io
service docker start
apt-get update
apt-get install -y maven
mvn -v
apt-get update && apt-get install -y openjdk-11-jdk