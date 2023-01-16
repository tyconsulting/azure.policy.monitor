@description('Specifies region of all resources.')
param location string = resourceGroup().location

@description('Function App Name.')
param functionAppName string = 'FN-PolicyMonitor'

@description('App Service Plan Name.')
param appServicePlanName string = 'ASP-PolicyMonitor'

@description('App Insights Name.')
param appInsightsName string = 'AI-PolicyMonitor'

@description('Storage Account Name.')
param storageAccountName string = 'sapolicymonitor'

@description('Key Vault Name.')
param keyVaultName string = 'KV-PolicyMonitor'

@description('Key Vault SKU name.')
param keyVaultSku string = 'Standard'

@description('Storage account SKU name.')
param storageSku string = 'Standard_LRS'

@description('App Service Plan SKU name.')
param appServicePlanSku string = 'Y1'

@description('Log Analytics Workspace Resource Id.')
param logAnalyticsWorkspaceResourceId string


var functionName = 'PolicyMonitor'
var functionAppKeySecretName = 'FunctionAppHostKey'
var logAnalyticsAPIVersion = '2021-06-01'
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSku
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: appInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

resource plan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    name: appServicePlanSku
  }
  properties: {
    reserved: true
  }
}

resource functionApp 'Microsoft.Web/sites@2021-02-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  properties: {
    
    enabled: true
    hostNameSslStates: [
      {
        name: '${functionAppName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${functionAppName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: plan.id
    reserved: true
    isXenon: false
    hyperV: false
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'python'
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageAccount.id, storageAccount.apiVersion).keys[0].value}'
        }
        {
          name: 'WORKSPACE_ID'
          value: '${reference(logAnalyticsWorkspaceResourceId, logAnalyticsAPIVersion).customerId}'
        }
        {
          name: 'WORKSPACE_KEY'
          value: '${listKeys(logAnalyticsWorkspaceResourceId, logAnalyticsAPIVersion).primarySharedKey}'
        }
      ]
      ftpsState: 'FtpsOnly'
      numberOfWorkers: 1
      linuxFxVersion: 'PYTHON|3.9'
    }
    httpsOnly: true
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}


resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: keyVaultSku
    }
    accessPolicies: []
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2019-09-01' = {
  name: '${keyVault.name}/${functionAppKeySecretName}'
  properties: {
    value: listKeys('${functionApp.id}/host/default', functionApp.apiVersion).functionKeys.default
  }
}

output functionAppHostName string = functionApp.properties.defaultHostName
output functionName string = functionName
