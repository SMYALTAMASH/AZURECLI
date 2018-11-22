#!/usr/bin/python
import subprocess
import json
import csv

# allBlobNames=str(subprocess.check_output("az storage account list | jq '.[]|.name+\",\"+.resourceGroup'| tr -d \"\\\"\" | tr \"\\n\" \",\" ", shell=True),"utf-8").split(",")
count=int(subprocess.check_output("az storage account list | jq '.[].name' | wc -l",shell=True))
c=0
rawData=str(subprocess.check_output("az storage account list",shell=True),"utf-8")
data=json.loads(rawData)


with open("auditData/allblobDetails.csv","w") as k:
	k=csv.writer(k)
	k.writerow(["ResourceGroup","StorageName","Location","Endpoint","Key","ContainerName"])
	while c < count:
		print(c+1)
		# print("RG: {} Storage: {} Location: {} Primary URL: {}".format(data[c]['resourceGroup'],data[c]['name'],data[c]['location'],data[c]['primaryEndpoints']['blob']))
		key=str(subprocess.check_output("az storage account keys list -g {} -n {} --query [0].value --output tsv".format(data[c]['resourceGroup'],data[c]['name']),shell=True),"utf-8")
		cont=str(subprocess.check_output("az storage container list --account-key '{}' --account-name '{}' --query [].name -o tsv| tr \"\\n\" \",\" ".format(key,data[c]['name']), shell=True),"utf-8").split(",")
		k.writerow([data[c]['resourceGroup'],data[c]['name'],data[c]['location'],data[c]['primaryEndpoints']['blob'],key,','.join(k for k in cont)])
		c=c+1
