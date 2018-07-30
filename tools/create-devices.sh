#!/bin/sh

usage() {
	echo "usage ${0} [-h hub_name] [-n number_of_devices]"
}

while getopts "h:n:" opt; do
	case $opt in
	h)	HUB=${OPTARG} ;;
	n)	NB_DEVICES=${OPTARG} ;;
	*)	usage ; exit 1 ;;
	esac
done
shift $(( $OPTIND - 1 ))

if [ $OPTIND = 1 ]; then
	usage
	exit 0
fi

for i in $(seq 1 $NB_DEVICES);
do
	az iot hub device-identity create \
	       	--edge-enabled true	  \
	       	--hub-name ${HUB}	  \
	       	--status enabled	  \
	       	--device-id edge$i

	CONNSTRING=$(az iot hub device-identity show-connection-string\
	      	--hub-name ${HUB} \
	       	--device-id edge$i\
		-o tsv)

	printf "%s:%s\n" edge$i $CONNSTRING >> edge-devices.txt
done
