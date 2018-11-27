#The King Never Fails To Win His Destiny

#create Resource Group
 az group create --name resourceGroup --location centralindia

#Query Resource Group
 az group list --query [].name --out tsv 

#Query VNET
 az network vnet list |jq '.[]| "Vnet_Name: "+ .name+  " Address_Space: "+ .addressSpace.addressPrefixes[] +" Resource_Group: "+ .resourceGroup'

#Create VNET
 az network vnet create -g resourceGroup -n vnet-name --address-prefix 11.4.0.0/16 

#Get VNET Subscription ID
 az network vnet show   --resource-group resourceGroup   --name vnet-name   --query id --out tsv

#Vnet Peering
 az network vnet peering create -g resourceGroup -n resourceGroup-peering --vnet-name vnet-name \
--remote-vnet-id vnet-id \
--allow-vnet-access

#Subnet Creation
 az network vnet subnet create --resource-group resourceGroup --vnet-name vnet-name \
  --name agent --address-prefix 11.4.0.0/24

#Query Subnet and Address Space
 az network vnet subnet list -g resourceGroup --vnet-name vnet-name | jq '.[]| "Subnet Name: "+ .name+" Address Space: "+ .addressPrefix'

#Create Availability Set
 az vm availability-set create -n az-name -g resourceGroup --platform-fault-domain-count 2 --platform-update-domain-count 2

#Query Availability Set
 az vm availability-set list -g resourceGroup | jq '.[].name'

#Create nsg
 az network nsg create --name nsg_name \
                      --resource-group resourceGroup

 #Query NSG creation
 az network nsg list -g resourceGroup | jq '.[].name'


#Query VM creation
 az vm list -g resourceGroup | jq '.[].name'

#azure blob creation
 az storage account create \
    --name testingss \
    --resource-group resourceGroup \
    --location centralindia \
    --sku Standard_LRS \
    --encryption blob

#Upload Content to Blob
 az storage blob upload \
--container-name containerName \
--file localhostFileName \
--name afterUploadFileNameInBlob  \
--account-name storageAccountName  \
--account-key accountKey

#Download Content from Blob
 az storage blob download \
--container-name containerName \
--file localhostFileName \
--name afterUploadFileNameInBlob  \
--account-name storageAccountName  \
--account-key accountKey

#copy all contents from one Continer to another
 az storage blob copy start-batch --destination-container destinationContainerName \
                           --source-container sourceContainerName \
                           --account-key destinationAccountKey \
                           --account-name destinationAccountName \
                           --source-account-key sourceAccountKey \
			   --source-account-name sourceAccountName

#copy only one file from one container to another
az storage blob copy start --destination-blob objectNameInConatinerAfterCopying \
                           --destination-container destinationContainerName \
                           --account-key destinationAccountKey \
                           --account-name destinationAccountName \
                           --source-account-key sourceAccountKey \
                           --source-account-name sourceAccountName \
                           --source-container sourceContainerName \
                           --source-blob objectToCopy

#Create A Container
az storage container create --name containerName \
                            --account-key storageAccountKey \
                            --account-name storageAccountName
                           

#List the contents in the blob
az storage blob list --container-name containerName \
                     --account-key storageAccountKey \
                     --account-name storageAccountName

#Delete from blob
az storage blob delete --container-name containerName \
                       --name fileNameToUpload \
                       --account-key storageAccountKey \
                       --account-name storageAccountName

#Get the Blob Size
az storage blob show \
			--name  fileSizeToknow \
			--container-name containerName \
			--account-name storageAccountName

#Open Port for a VM
az vm open-port --port portNumber -g resourceGroup --name ruleName

#Listing All the Blobs
az storage account list | jq '.[]|.resourceGroup+","+.name'

#Getting the Keys of Specific Blob
az storage account keys list -g resourceGroup -n storageAccountName --query [0].value --output tsv

#Get the available cores and CPU's for the server
az vm list-vm-resize-options -g resourceGroup -n serverName -o table

#Resize the VM with Upgraded VM(Get the resize name from the above command)
az vm resize --resource-group myResourceGroup --name myVM --size Standard_DS3_v2

#Get the VM size and name
az vm list -g production_all | jq '.[]| .name+" "+ .hardwareProfile.vmSize'

#Get the size of the scaleset
az vmss list-instances -g swarm-production-1 -n swarmm-agentpublic-49420225-vmss | jq '.[]| .name+" "+.sku.name'

#Create an sts token for the blob
khatam=`date -d "5 days" '+%Y-%m-%dT%H:%MZ'`
az storage blob generate-sas --container-name containerName \
                             --name blobName \
                             --account-name storageAccountName \
                             --account-key storageAccountKey \
                             --https-only \
                             --permissions r \
                             --expiry $khatam
