#!/bin/bash

## Common Functions
CheckRoot() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
    fi
}

CheckSELinux() {
    if [ "$(getenforce)" != "Disabled" ]; then
        echo "SELINUX is enabled. Disabling it..."
        setenforce 0
    fi
}

CheckFirewall() {
    systemctl status firewalld &>/dev/null
    if [ $? -eq 0 ]; then
        echo "Firewall is running. Stopping it..."
        systemctl stop firewalld
    fi
}

success() {
    echo -e "\e[32m✓  $1\e[0m"
}

error() {
    echo -e "\e[31m✗  $1\e[0m"
    exit 1
}

## Checking Root User or not.
CheckRoot

## Checking SELINUX Enabled or not.
CheckSELinux

## Checking Firewall on the Server.
CheckFirewall

which java &>/dev/null
if [ $? -ne 0 ]; then
    ## Downloading and Installing Java
    yum install java wget -y &>/dev/null
    if [ $? -eq 0 ]; then
        success "JAVA Installed Successfully"
    else
        error "JAVA Installation Failure!"
    fi
else
    success "Java already Installed"
fi

## Fetching the latest Nexus download URL
URL="https://download.sonatype.com/nexus/3/nexus-3.64.0-04-unix.tar.gz"
NEXUSFILE=$(basename $URL)
NEXUSDIR=$(echo $NEXUSFILE | sed -e 's/-unix.tar.gz//')
NEXUSFILE="/opt/$NEXUSFILE"
wget $URL -O $NEXUSFILE &>/dev/null
if [ $? -eq 0 ]; then
    success "NEXUS Downloaded Successfully"
