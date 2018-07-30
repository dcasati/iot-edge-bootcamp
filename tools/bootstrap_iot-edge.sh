#!/bin/sh

usage() {
	echo "usage ${0} [-c device]"
}

while getopts "d:h" opt; do
	case $opt in
	d)	DEVICE=${OPTARG} ;;
	h)	usage ; exit 0 ;;
	*)	usage ; exit 1 ;;
	esac
done
shift $(( $OPTIND - 1 ))

if [ $OPTIND = 1 ]; then
	usage
	exit 0
fi

# Install repository configuration
curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list > ./microsoft-prod.list
sudo cp ./microsoft-prod.list /etc/apt/sources.list.d/

# Install Microsoft GPG public key
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo cp ./microsoft.gpg /etc/apt/trusted.gpg.d/

# Perform apt upgrade
sudo apt-get upgrade

# Install the container runtime
sudo apt-get update

sudo apt-get install -y moby-engine
sudo apt-get install -y moby-cli

sudo apt-get update
sudo apt-get install -y iotedge

sudo systemctl restart iotedge

# verify the installation
systemctl status iotedge

sudo iotedge list

# install iotedgectl
apt-get install -y python-pip
pip install -U azure-iot-edge-runtime-ctl

CONNID=$(awk -F: /${DEVICE}/'{print $2}' conf/edge-devices.txt)
iotedgectl setup --connection-string "${CONNID}" --nopass
