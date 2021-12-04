# Bicep Template for the Event Grid Subscription

```bash
rg="rg-policy-monitor"
functionApp="FN-PolicyMonitor"
subId=$(az account show | jq '.id' | tr -d '"')
functionAppResourceId="/subscriptions/$subId/resourceGroups/$rg/providers/Microsoft.Web/sites/$functionApp/functions/PolicyMonitor"

az deployment group create --resource-group $rg --template-file main.bicep --parameters functionAppResourceId=$functionAppResourceId

```
