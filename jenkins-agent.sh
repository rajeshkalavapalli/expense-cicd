#!/bin/bash 
yum install fontconfig java-17-openjdk -y 
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
yum -y install terraform -y 

# installing node 
dnf module disable nodejs -y
dnf module enable nodejs:20 -y
dnf install nodejs -y

# installing zip 

yum install zip -y 
