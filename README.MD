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



