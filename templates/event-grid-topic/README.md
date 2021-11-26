# Bicep template for the Event Grid System Topic for PolicyInsights

```bash
rg="rg-policy-monitor"

az group create --name $rg --location australiaeast

az deployment group create --resource-group $rg --template-file main.bicep

```