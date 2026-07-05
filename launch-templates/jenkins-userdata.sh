#!/bin/bash
set -e

exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "Starting Jenkins Installation..."

apt update -y
apt upgrade -y

apt install -y fontconfig openjdk-21-jre curl gnupg

systemctl restart networkd-dispatcher.service || true
systemctl restart systemd-logind.service || true
systemctl restart unattended-upgrades.service || true

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | \
tee /usr/share/keyrings/jenkins-keyring.asc >/dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
tee /etc/apt/sources.list.d/jenkins.list >/dev/null

apt update -y

apt install -y jenkins

systemctl enable jenkins
systemctl start jenkins

if command -v ufw >/dev/null 2>&1; then
    ufw allow 8080 || true
    ufw --force reload || true
fi

echo "======================================================" >/home/ubuntu/jenkins-info.txt
echo "Jenkins Installed Successfully" >>/home/ubuntu/jenkins-info.txt
echo "" >>/home/ubuntu/jenkins-info.txt
echo "Admin Password:" >>/home/ubuntu/jenkins-info.txt
cat /var/lib/jenkins/secrets/initialAdminPassword >>/home/ubuntu/jenkins-info.txt
echo "" >>/home/ubuntu/jenkins-info.txt

PUBLIC_IP=$(curl -s http://checkip.amazonaws.com)

echo "Access Jenkins at: http://${PUBLIC_IP}:8080" >>/home/ubuntu/jenkins-info.txt

chown ubuntu:ubuntu /home/ubuntu/jenkins-info.txt

echo "Jenkins installation completed."