#!/bin/bash
sudo curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
yum install fontconfig java-17-openjdk -y 
yum install jenkins -y
systemctl daemon-reload
systemctl start jenkins -y 

