# Azure Policy Monitor

## Setting up demo environment

Setting up demo environment described in doco: [Tutorial: Route policy state change events to Event Grid with Azure CLI](https://docs.microsoft.com/en-us/azure/governance/policy/tutorials/route-state-change-events)

```bash
# Get subscription Id
subId=$(az account show | jq '.id' | tr -d '"')

# variables
rg="rg-policy-monitor-demo"
templateUri="https://raw.githubusercontent.com/Azure-Samples/azure-event-grid-viewer/master/azuredeploy.json"
siteName="policyInsights"
evtSubName="policyInsightsEvtSub"
# Log in first with az login if you're not using Cloud Shell
az group create --name $rg --location australiaeast

# Log in first with az login if you're not using Cloud Shell

az eventgrid system-topic create --name PolicyStateChanges --location global --topic-type Microsoft.PolicyInsights.PolicyStates --source "/subscriptions/$subId" --resource-group $rg

# Create message endpoint
az deployment group create --resource-group $rg --template-uri $templateUri --parameters siteName=$siteName hostingPlanName=viewerhost

# Subscribe to the system topic

az eventgrid system-topic event-subscription create --name $evtSubName --resource-group $rg --system-topic-name PolicyStateChanges --endpoint "https://$siteName.azurewebsites.net/api/updates"
```

## Test demo

```bash
policyDefId=$(az policy definition list --query "[?displayName=='Require a tag on resource groups']" | jq  '.[0]' | jq ".id"| tr -d '"')

az policy assignment create --name 'requiredtags-events' --display-name 'Require tag on RG' --scope "/subscriptions/$subId" --policy $policyDefId --params '{ "tagName": { "value": "EventTest" } }'

```

## Manually deploy the code

### 1. deploy funciton app

```bash
az functionapp create --consumption-plan-location westeurope --runtime python --runtime-version 3.8 --functions-version 3 --name <APP_NAME> --os-type linux
```