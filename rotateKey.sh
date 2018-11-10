#!/bin/bash

vmnames=( server-1 server-2 )

for name in "${vmnames[@]}"
do
	#Rotating SSH Pem Key
	echo "changing key for server $name my master"
	echo "------------------------------------------------------------------"
	az vm user update --name $name \
			  --resource-group myresourceGroupName \
			  --username ops \
			  --ssh-key-value 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2V3rrw8/9gSiesdzRd/W5a48irWpkkkPPAFLygd3pbmbtV1idBOk3O3EpmDWaNU39hD6OzHIR3 king@king'
	echo "------------------------------------------------------------------"
done
