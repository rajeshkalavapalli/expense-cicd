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

## Installing html2text
yum install https://kojipkgs.fedoraproject.org/packages/python-html2text/2016.9.19/1.el7/noarch/python2-html2text-2016.9.19-1.el7.noarch.rpm -y &>/dev/null
if [ $? -ne 0 ]; then
    error "Failed to install python-html2text"
fi

## Fetching the latest Nexus download URL
URL=$(curl -L -s https://help.sonatype.com/display/NXRM3/Download+Archives+-+Repository+Manager+3 | html2text | grep -Eo 'https://download.sonatype.com/nexus/3/[^"]+unix.tar.gz' | head -1)
if [ -z "$URL" ]; then
    error "Failed to fetch the latest Nexus download URL"
fi

## Downloading Nexus
NEXUSFILE=$(basename $URL)
NEXUSDIR=$(echo $NEXUSFILE | sed -e 's/-unix.tar.gz//')
NEXUSFILE="/opt/$NEXUSFILE"
wget $URL -O $NEXUSFILE &>/dev/null
if [ $? -eq 0 ]; then
    success "NEXUS Downloaded Successfully"
else
    error "NEXUS Downloading Failure"
fi

## Adding Nexus User
id nexus &>/dev/null
if [ $? -ne 0 ]; then
    useradd nexus
    if [ $? -eq 0 ]; then
        success "Added NEXUS User Successfully"
    else
        error "Adding NEXUS User Failure"
    fi
fi

## Extracting Nexus
if [ ! -d "/home/nexus/$NEXUSDIR" ]; then
    su nexus <<EOF
cd /home/nexus
tar xf $NEXUSFILE
EOF
    if [ $? -eq 0 ]; then
        success "Extracted NEXUS Successfully"
    else
        error "Extracting NEXUS Failed"
    fi
fi

## Setting Nexus startup
unlink /etc
