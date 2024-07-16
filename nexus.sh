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
    yum install java-1.8.0-openjdk wget -y &>/dev/null
    if [ $? -eq 0 ]; then
        success "JAVA Installed Successfully"
    else
        error "JAVA Installation Failure!"
    fi
else
    success "Java already Installed"
fi

## Fetching the latest Nexus download URL using curl with insecure option
URL="https://sonatype-download.global.ssl.fastly.net/repository/downloads-prod-group/3/nexus-3.70.1-02-unix.tar.gz"
NEXUSFILE="/opt/latest-unix.tar.gz"

# Debugging: Print URL and Nexus file details
echo "Nexus download URL: $URL"
echo "Nexus file: $NEXUSFILE"

curl -Lk $URL -o $NEXUSFILE
if [ $? -eq 0 ]; then
    success "NEXUS Downloaded Successfully"
else
    # Debugging: Print curl output for further analysis
    echo "curl output:"
    curl -Lk $URL -o $NEXUSFILE
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
if [ ! -d "/home/nexus/latest-unix" ]; then
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
if [ ! -d "/home/nexus/latest-unix/bin/" ]; then
    mkdir -p /home/nexus/latest-unix/bin/
fi

echo "run_as_user=nexus" >/home/nexus/latest-unix/bin/nexus.rc

# Creating a systemd service file for Nexus
cat <<EOF >/etc/systemd/system/nexus.service
[Unit]
Description=nexus service
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/home/nexus/latest-unix/bin/nexus start
ExecStop=/home/nexus/latest-unix/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

# Enabling and starting Nexus service
systemctl enable nexus
systemctl start nexus

if [ $? -eq 0 ]; then
    success "Nexus Service Started Successfully"
else
    error "Starting Nexus Service Failed"
    systemctl status nexus
    journalctl -xeu nexus.service
fi
