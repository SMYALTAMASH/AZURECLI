#!/bin/bash
####################################################################################################


Folder=auditData
tmpdir=$Folder/tmp
AppGatewayFile=$Folder/AppGatewayDetails.csv
RGFile=$Folder/ResourceGroupDetails.csv
VMFile=$Folder/VMBasicMetrics.csv
VMCPU=$Folder/VMCPUPercentage.csv
Blob=$Folder/BlobDetails.csv
IPDetails=$Folder/VMIPDetails.csv
Limit=$Folder/ResourceLimit.csv
CDNProfiles=$Folder/CDNProfiles.csv
number_of_days=60

mkdir -p $Folder
mkdir -p $tmpdir
# Get all the resource Groups and its locations
echo "Storing Resource Groups List in $RGFile"
echo "-------------------------------------------------"

echo "Resource Group Name , Location" > $RGFile
az group list -o table | awk 'NR>2{print $1,$2}' | tr " " "," >> $RGFile &
RG=$(cat $RGFile | awk '{print $1}' | cut -d "," -f1 | tr "\n" " ")


echo "Storing VM List in $VMFile"
echo "-------------------------------------------------"

#echo "RESOURCE GROUP, Name, Location, Instance Type, HDD SIZE, OS, STATE" > $VMFile
#az vm list -d | jq '.[] | .resourceGroup+","+.name+","+.location+","+.hardwareProfile.vmSize+","+(.storageProfile.osDisk.diskSizeGb|tostring)+","+(.storageProfile.imageReference|.offer+" "+.sku)+","+.powerState' | tr -d "\"" >> $VMFile 

echo "RESOURCE GROUP, Name, Location, Instance Type, HDD SIZE, OS" > $VMFile
az vm list | jq '.[] | .resourceGroup+","+.name+","+.location+","+.hardwareProfile.vmSize+","+(.storageProfile.osDisk.diskSizeGb|tostring)+","+(.storageProfile.imageReference|.offer+" "+.sku)' | tr -d "\"" >> $VMFile 

echo "-------------------------------------------------"
#echo "Analizing Application Gateway operations in $AppGatewayFile"
#
#echo "NAME,  RESOURCE GROUP, TYPE, CAPACITY, CERTIFICATES, BACKENDPOOL NAME, BACKENDPOOL IPS, HTTP SETTINGS,HTTP PORT CONFIGURATIONS, HTTP STATUS" > $AppGatewayFile
#az network application-gateway list | jq -r '.[]| .name+","+.resourceGroup+","+.sku.name+","+(.sku.capacity|tostring)+","+.authenticationCertificates[].name+","+.backendAddressPools[].name+","+[.backendAddressPools[].backendAddresses[].ipAddress]|join(",")+","+.backendHttpSettingsCollection[].name+","+(.backendHttpSettingsCollection[].port|tostring)+","+.backendHttpSettingsCollection[].provisioningState' >> $AppGatewayFile &

echo "Storing The Blob Details in $Blob"
echo "-------------------------------------------------"

echo "Resource Group, Storage Name,Created On,Type, Location,Primary Endpoint For Blob, Primary Endpoint For File" > $Blob
az storage account list | jq '.[] | .resourceGroup+","+.name+","+.creationTime+","+.sku.name+","+.location+","+.primaryEndpoints.blob+","+.primaryEndpoints.file'| tr -d "\"" >> $Blob &

echo "Storing The Server Ip Details in $IPDetails"
echo "-------------------------------------------------"

echo "Resource Group, Server Name,Private IP, Public IP" > $IPDetails
az vm list-ip-addresses | jq '.[]|.virtualMachine.resourceGroup+","+.virtualMachine.name+","+.virtualMachine.network.privateIpAddresses[0]+","+.virtualMachine.network.publicIpAddresses[0].ipAddress' | tr -d "\"" >> $IPDetails &

echo "Storing The CDN Profiles in $CDNProfiles" 
echo "-------------------------------------------------"

echo "Resource Group, Name, Location, Type" > $CDNProfiles
az cdn profile list | jq -r '.[]|.resourceGroup+","+.name+","+.location+","+.sku.name' >> $CDNProfiles &

echo "Storing The Account Limits of All the regions in $Limit" 
echo "-------------------------------------------------"

echo "Name, Current Value, Limit" > $Limit
for Subscription in $(az account list | jq '.[].id' | tr -d "\"" | tr "\n" " ");
do
	echo "Subscription:, $Subscription" >> $Limit
echo "," >> $Limit
for loc in $(az account list-locations | jq '.[].name' | tr -d "\"" | tr "\n" " ");
	do
		echo "Region:, $loc" >> $Limit
		az vm list-usage --subscription $Subscription -l $loc | jq '.[]| .localName+","+.currentValue+","+.limit' | tr -d "\"" >> $Limit &
	done
done

echo "Getting All The Blob Details"
python3 getblobDetails.py &

echo "Storing VM CPU Usage in $VMCPU"
echo "-------------------------------------------------"

echo "Resource Group , Server , Max Spike Value , Spike Time  , Number Of Days , Average Of Max" > $VMCPU

range=$(echo "$(cat $VMFile | wc -l)" | bc)

sed 1d $VMFile | while IFS=',' read -r RGCPUName UnParsedVM
do

	VMCPUName=$(echo "$UnParsedVM" | cut -d ',' -f1 )
	
	echo "Analizing MAX CPU Usage for VM $VMCPUName in $RGCPUName Resource group"

	max_json=$(az monitor metrics list -g $RGCPUName --metric "Percentage CPU" --resource $VMCPUName --resource-type Microsoft.Compute/virtualMachines --start-time $(date --date="$number_of_days days ago" +"%Y-%m-%dT00:00:00Z") --aggregation Maximum)
	
	max_metrics=$(echo "$max_json" | jq -r '.value[].timeseries[].data[]| select(.maximum != null)| .maximum' | sort -n | tail -n $number_of_days)

	echo "$max_json" > $tmpdir/$VMCPUName

	all_metrics=$(echo "$max_metrics" | paste -sd "+")

	max_obtained_val=$(echo $max_metrics | awk '{ print $NF }')

	echo "Max CPU Used is $max_obtained_val"

	max_timestamp=$(echo $max_json | jq -r --arg max_obtained_val "$max_obtained_val" '.value[].timeseries[].data[]| select(.maximum == env.max_obtained_val) | .timeStamp' | tr "\n" " " )

	max_average=$(echo "($all_metrics)/$number_of_days" | bc)

	echo "$RGCPUName , $VMCPUName , $max_obtained_val , $max_timestamp , $number_of_days , $max_average" >> $VMCPU

done 

wait

echo "-------------------------------------------------"
echo "-------------------------------------------------"
echo "-------------------------------------------------"
echo "Stored Audit Data in $Folder"
echo "-------------------------------------------------"
echo "-------------------------------------------------"
echo "-------------------------------------------------"
