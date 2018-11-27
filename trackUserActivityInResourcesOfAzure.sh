#!/bin/bash
#The King Never Fails To Win His Destiny
ResourceGroupName=( `az group list | jq '.[].name' | tr -d "\"" | tr "\n" " "` )
before90Days=$(date --date="89 days ago" +"%Y-%m-%dT00:00:00Z")
for name in "${ResourceGroupName[@]}"
do
	echo "-----------------------------------------------------------------"
	echo "Resource Group: $name"
	az monitor activity-log list --resource-group $name --start-time $before90Days | jq '.[] |"User: "+ .caller+", Operation: "+.category.localizedValue+", Timestamp: "+.eventTimestamp' | jq 'select(.!= null)'
	echo "-----------------------------------------------------------------"
done
