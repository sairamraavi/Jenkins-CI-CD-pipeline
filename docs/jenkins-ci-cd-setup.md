# Jenkins-CI-CD-pipeline

Jenkins pipeline that automates the testing and deployment of a simple Python web application

# Install Jenkins in the EC2

### Prerequisites

Before running commands, ensure your AWS EC2 Security Group has an inbound rule allowing Custom TCP on port 8080 from your IP address or 0.0.0.0/0

Step 1:Launch Ec2 instace and connect, update the OS 

```bash
sudo apt update && sudo apt upgrade -y
```

Step 2: Install Java (Required)

```bash
sudo apt install -y fontconfig openjdk-21-jre
```

```bash 
sudo systemctl restart networkd-dispatcher.service
sudo systemctl restart systemd-logind.service
sudo systemctl restart unattended-upgrades.service
```

```bash
java --version
```

Step 3: Add the Jenkins Repository and GPG KeyThe default Ubuntu package registries often hold older Jenkins releases. Add the official Jenkins repository to obtain the most up-to-date stable

```bash
sudo curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | sudo tee \
/usr/share/keyrings/jenkins-keyring.asc > /dev/null
```

``` bash
sudo echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
/etc/apt/sources.list.d/jenkins.list > /dev/null
```

Step 4: Install Jenkins
Update the package list again and install Jenkins.

```bash
sudo apt update
sudo apt install -y jenkins
```

Reboot the application

```bash
sudo reboot 
```

Step 5: Start and Enable Jenkins Service
Start Jenkins and enable it to run on system boot

```bash
sudo systemctl start jenkins
```

Check the service status:

```bash
sudo systemctl status jenkins
```

Step 6: Allow Jenkins Port (Firewall)
If UFW is enabled, allow port 8080.

```bash
sudo ufw allow 8080
sudo ufw reload
```

Step 7: Get Jenkins Initial Admin Password
To unlock Jenkins, retrieve the initial admin password.

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Step 8: Access Jenkins Web UI
Open your browser and visit:
http://<EC2_PUBLIC_IP>:8080
