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
unlink /etc/init.d/nexus &>/dev/null
ln -s /home/nexus/$NEXUSDIR/bin/nexus /etc/init.d/nexus
echo "run_as_user=nexus" >/home/nexus/$NEXUSDIR/bin/nexus.rc
CONFIG_FILE=$(find /home/nexus/ -name nexus-default.properties)
sed -i -e '/nexus.scripts.allowCreation/ d' $CONFIG_FILE
sed -i -e '$ a nexus.scripts.allowCreation=true' $CONFIG_FILE
pip3 install nexus3-cli &>/tmp/nexus-install.log

success "Updating System Configuration"
systemctl enable nexus &>/dev/null
systemctl start nexus
if [ $? -eq 0 ]; then
    success "Starting Nexus Service"
else
    error "Starting Nexus Failed"
fi

