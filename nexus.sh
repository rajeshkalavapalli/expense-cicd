#!/bin/bash

## Source Common Functions
# source /tmp/labautomation/dry/common-functions.sh

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
        exit 1
    fi
else
    success "Java already Installed"
fi

## Installing html2text
yum install https://kojipkgs.fedoraproject.org/packages/python-html2text/2016.9.19/1.el7/noarch/python2-html2text-2016.9.19-1.el7.noarch.rpm -y &>/dev/null
if [ $? -ne 0 ]; then
    error "Failed to install python-html2text"
    exit 1
fi

## Fetching the latest Nexus download URL
URL=$(curl -L -s https://help.sonatype.com/display/NXRM3/Download+Archives+-+Repository+Manager+3 | html2text | grep -Eo 'https://download.sonatype.com/nexus/3/[^"]+unix.tar.gz' | head -1)
if [ -z "$URL" ]; then
    error "Failed to fetch the latest Nexus download URL"
    exit 1
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
    exit 1
fi

## Adding Nexus User
id nexus &>/dev/null
if [ $? -ne 0 ]; then
    useradd nexus
    if [ $? -eq 0 ]; then
        success "Added NEXUS User Successfully"
    else
        error "Adding NEXUS User Failure"
        exit 1
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
        exit 1
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
    exit 1
fi
