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
# inside jenkis container run these commands to see
find / -name "pom.xml" 2>/dev/null
/var/jenkins_home/workspace/java/pom.xml
cd /var/jenkins_home/workspace/java
mvn clean verify sonar:sonar
# Install Git in Container because we are running job for sonarqube its not working it cant find pom.xml in container because jenkins is in the container
apt-get update && apt-get install -y git
cd /var/jenkins_home/workspace
rm -rf java && git clone https://github.com/vishal1142/java.git
cd java && git pull origin main
git clone https://github.com/vishal1142/java.git java-fresh
# Step-by-Step Guide for Fixing the Git Issue in Your Jenkins Docker Container (72a9d8671613):
docker exec -u root -it 72a9d8671613 bash
chown -R jenkins:jenkins /var/jenkins_home/workspace
chmod -R 775 /var/jenkins_home/workspace
# sonar stage fails due to local host
ipconfig
you will find ip and make changes in file and also in manage jenkins http://192.168.1.141:9000
# QualityGateStatus error to configure in Sonarqube
Create Webhook
Name*
sonarhooks
URL*
http://192.168.1.141:8080/sonarqube-webhook/
Secret
sonarqube-webhook-2025

# 🚨 What’s Happening:

The waitForQualityGate() step blocks until SonarQube finishes analysis and sends a webhook back to Jenkins.

If no webhook is received, Jenkins keeps waiting — indefinitely — even if the analysis is complete on the SonarQube side.

🔍 Why Your Pipeline Is Stuck or Delayed:
Webhook isn't reaching Jenkins:

Most likely reason.

Even though you’ve set http://192.168.1.141:8080/sonarqube-webhook/, the network might not be allowing SonarQube to reach Jenkins (firewall, Docker, etc).

Jenkins URL config is wrong or inaccessible:

Jenkins might not be reachable via http://192.168.1.141:8080 from inside the SonarQube container or host.

You’re running Jenkins in Docker without port mapping:

If Jenkins is containerized, make sure the host machine’s IP is correctly mapped and reachable.

if bash: curl: command not found
apt update && apt install curl -y
curl -X POST http://192.168.1.100:8080/sonarqube-webhook/ -d '{}'
if it is not accesible from sonar container to jenklins container then follow below steps
Let's Fix It
check container name with id 
docker inspect <container-id> --format '{{.Name}}'
you will get 
72a9d8671613   jenkins/jenkins:lts-jdk11   ...   my-jenkins-server
Create a Shared Docker Network
docker network create jenkins-sonar-net
1. Connect Both Containers to It
docker network connect jenkins-sonar-net my-jenkins-server
2. Connect my-sonarqube:
docker network connect jenkins-sonar-net my-sonarqube
3. Update the SonarQube Webhook
http://my-jenkins-server:8080/sonarqube-webhook/
4. ✅ Double-Check This
docker network inspect bridge
or
docker network ls
docker inspect <network_name>
NOw it now it works perfectly.
Commit the container as a new image
docker commit my-jenkins-server my-jenkins-server-backup
docker commit my-jenkins-server my-jenkins-server-backup
Run a new container with Docker socket mounted
docker run -d --name my-jenkins-server-new -u root -p 8080:8080 -p 50000:50000 -v /var/run/docker.sock:/var/run/docker.sock -v jenkins_home:/var/jenkins_home my-jenkins-server-backup






