#!/bin/bash
# Author <S M Y ALTAMASH> <smy.altamash@gmail.com>
# This script helps to increase the azure Disk size by Deallocating the disk, Increasing the DIsk and starting it back.
# Note: If you have public IP attached make sure it is static else it will get changed.
# Update VMS by space separated server names RG with the Resource group name and DISKSIZE with the Size required for the virtual Machine.

# Variables required for disk changes
VMS=( 5nodeJenkins-1 Server-2 )
RG=Test
DISKSIZE=100

#####################################

for VM in ${VMS[@]};
do

echo "Changing disk for $VM"

# Deallocate the VM First
echo "Deallocating the $VM VM First"
az vm deallocate \
    --resource-group $RG \
    --name $VM

# Query that the VM is Deallocated
echo "Query that the $VM VM is Deallocated"
az vm list \
    --resource-group $RG \
    --query "[?name == '$VM'].{Name:name, PowerState:powerState}" \
    --show-details \
    --output table

# Get the Disk ID

DISKID=$(az vm list -g $RG \
            --query "[?name == '$VM'].storageProfile.osDisk.managedDisk.id" \
            --output tsv)

echo "The Disk ID=$DISKID"

# Increase the Disk Size
echo "Increase the Disk Size to $DISKSIZE GB"

az disk update \
    --ids $DISKID \
    --size-gb $DISKSIZE

# Start Back the VM
echo  "Starting Back $VM VM"

az vm start -g $RG -n $VM

done
