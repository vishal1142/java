git init
git add .
git commit -m "Initial commit"
#to check
git remote -v
git remote remove origin
git remote add origin https://github.com/vishal1142/Fullcicd.git
git branch

git rm --cached jenkins-user_credentials.csv
echo "jenkins-user_credentials.csv" >> .gitignore
git add .gitignore
git commit -m "Remove secrets and update .gitignore"
git push -u origin main
git push -u origin main --force
git lfs install
git lfs track "*.exe"

git add .gitattributes
git add eks_module/.terraform/providers/registry.terraform.io/hashicorp/aws/3.76.1/windows_amd64/terraform-provider-aws_v3.76.1_x5.exe
git commit -m "Track large .exe file using Git LFS"

# Remove the file from Git history (not just current commit)

git rm --cached -r eks_module/.terraform
git commit -m "Remove .terraform and large files from Git tracking"

# If the large .exe file was added in a previous commit, run this to clean history:
git filter-repo --path .terraform --invert-paths

# If you don’t have git filter-repo, install it:
brew install git-filter-repo  # macOS
sudo apt install git-filter-repo  # Ubuntu/Debian

# . Force push cleaned repo
git push origin --force

# Alternative (if you prefer to start clean)
# If you don’t mind starting fresh:

rm -rf .git
git init
echo ".terraform/" >> .gitignore
echo "*.exe" >> .gitignore
git add .
git commit -m "Initial commit without .terraform"
git remote add origin https://github.com/vishal1142/java.git
git push -u origin main --force

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
 Give Jenkins user Docker permissions
groupadd docker || true
usermod -aG docker jenkins

---------------------------------------------------------------------------------------------------------------------------------------------------


### 🔥 Root Cause:
`/var/run/docker.sock` is **owned by group `root`**, not `docker`. That’s why your `jenkins` user can't access it, and also:  
🔸 `usermod` isn't available for the `jenkins` user (as expected — only `root` can use it).

---

### ✅ Let’s Fix It As `root` (inside the container)

1. **Switch to root user inside the container (you've done this):**
```bash
docker exec -u root -it my-jenkins-server bash
```

2. **Change the group of the Docker socket to `docker`:**
```bash
groupadd docker 2>/dev/null || true   # just in case it's not there
chgrp docker /var/run/docker.sock
chmod 660 /var/run/docker.sock
```

3. **Add `jenkins` user to the `docker` group:**
```bash
usermod -aG docker jenkins
```

4. **Verify:**
```bash
id jenkins
```
You should see:  
`groups=1000(jenkins),999(docker)` (or similar).

5. **Restart the container** so the group membership change takes effect:
```bash
exit
docker restart my-jenkins-server
```

6. **Re-enter as jenkins and test:**
```bash
docker exec -u jenkins -it my-jenkins-server bash
docker ps
```

---

### ✅ BONUS: One-liner fix (run as root)
If you're in a hurry and just want it fixed:
```bash
docker exec -u root my-jenkins-server bash -c "groupadd docker || true && usermod -aG docker jenkins && chgrp docker /var/run/docker.sock && chmod 660 /var/run/docker.sock"
docker restart my-jenkins-server
```

Let me know how it goes! 🚀

---------------------------------------------------------------------------------------------------------------------------------------------------

Looks like you're inside a container or a minimal Linux environment where the `vi` editor isn't installed. If you want to edit `trivy.sh`, you’ve got a few options:

---

### 🔧 **Option 1: Use `nano` (if available)**
Try:
```bash
nano trivy.sh
```

If you get a similar error (`command not found`), it’s also not installed.

---

### 🛠 **Option 2: Install `vi` or `vim`**
If you're able to install packages inside this environment (and have internet access), try:

For **Debian/Ubuntu** based containers:
```bash
apt update && apt install -y vim
```

For **Alpine**:
```bash
apk add vim
```

For **CentOS/RHEL**:
```bash
yum install -y vim
```

---

### ✍️ **Option 3: Echo script content**
Quick and dirty way to write a small script:
```bash
echo -e '#!/bin/bash\ntrivy image your-image-name' > trivy.sh
chmod +x trivy.sh
```

---

### 🚀 Want to continue?

Ah, you're getting `Permission denied` — that usually means the script doesn’t have execute permissions. Let's fix that.

---

### ✅ Step 1: Add execute permission
Run this:
```bash
chmod +x trivy.sh
```

Then confirm with:
```bash
ls -l trivy.sh
```

You should see:
```
-rwxr-xr-x 1 root root ... trivy.sh
```

---

### ✅ Step 2: Run the script again
Now try:
```bash
./trivy.sh
```
# verify 
trivy --version

---------------------------------------------------------------------------------------------------------------------------------------------------


# Safer alternative using Eclipse Temurin
FROM eclipse-temurin:21-jdk-jammy
WORKDIR /app
COPY ./target/*.jar /app.jar
CMD ["java", "-jar", "app.jar"]

---------------------------------------------------------------------------------------------------------------------------------------------------
aws configure
aws sts get-caller-identity
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 131664697495.dkr.ecr.us-east-2.amazonaws.com
docker exec -it 72a9d8671613 /bin/bash

docker tag vishal:latest 131664697495.dkr.ecr.us-east-2.amazonaws.com/vishal:latest

docker push 131664697495.dkr.ecr.us-east-2.amazonaws.com/vishal:latest

*******************************************************************************************************


| Purpose                             | Why It's Needed                                                                              |
| ----------------------------------- | -------------------------------------------------------------------------------------------- |
| **Artifact Repository**             | Stores and manages JARs, WARs, libraries, and other build artifacts from Maven, Gradle, etc. |
| **Docker Registry**                 | Acts as a private Docker registry for storing custom Docker images securely.                 |
| **Centralized Artifact Management** | Keeps all artifacts in one place, with versioning and access control.                        |
| **Build Optimization**              | Speeds up builds via local cache of dependencies instead of downloading from public repos.   |
| **Security and Compliance**         | Prevents usage of unauthorized or vulnerable dependencies.                                   |
| **Promotion & Staging**             | Enables artifact promotion through development, staging, and production stages.              |



**************************************************************

MOST COMMON ERRORS

1. NEED TO CHANGE SINAR IP in Jenkins settings, jenkinsfile and pom.xml
2. Docker  permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock = follow above points