//WIP!
targetScope = 'subscription'

@description('Environment for the deployment.')
param env string

@description('Core name for the spoke.')
param spokeName string

@description('Location for all resources inherited from the deployment.')
param location string = deployment().location

@description('The confirguration for the storage account.')
param storageConfig object

@description('The configuration for the function app.')
param functionConfig object

var rgName = 'rg-${spokeName}-${env}'
var storageAccountName = 'st${replace(spokeName, '-', '')}${env}'
var appServicePlanName = 'asp-${spokeName}-${env}'
var functionAppName = 'fct-${spokeName}-${env}'
var logAnalyticsWorkspaceName = 'log-${spokeName}-${env}'
var appInsightsName = 'appi-${spokeName}-${env}'

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: rgName
  location: location
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.19.0' = {
  scope: rg
  name: 'deploy-${storageAccountName}'
  params: {
    name: storageAccountName
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    skuName: storageConfig.skuName
    kind: storageConfig.kind
    supportsHttpsTrafficOnly: storageConfig.supportsHttpsTrafficOnly
    minimumTlsVersion: storageConfig.minimumTlsVersion
  }
}

module logAnalyticsWorkspace 'br/public:avm/res/operational-insights/workspace:0.11.1' = {
  scope: rg
  name: 'deploy-${logAnalyticsWorkspaceName}'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
  }
}

module appInsight 'br/public:avm/res/insights/component:0.6.0' = {
  scope: rg
  name: 'deploy-${appInsightsName}'
  params: {
    name: appInsightsName
    workspaceResourceId: logAnalyticsWorkspace.outputs.resourceId
    location: location
  }
}

module serverfarm 'br/public:avm/res/web/serverfarm:0.4.1' = {
  scope: rg
  name: 'deploy-${appServicePlanName}'
  params: {
    name: appServicePlanName
    kind: 'linux'
    location: location
    skuName: functionConfig.skuName
  }
}

module functionApp 'br/public:avm/res/web/site:0.15.1' = {
  scope: rg
  name: 'deploy-${functionAppName}'
  params: {
    name: functionAppName
    kind: 'functionapp'
    serverFarmResourceId: serverfarm.outputs.resourceId
    managedIdentities: {
      systemAssigned: true
    }
    appSettingsKeyValuePairs: {
      FUNCTIONS_EXTENSION_VERSION: '~4'
      FUNCTIONS_WORKER_RUNTIME: 'java'
    }
    siteConfig: functionConfig.siteConfig
    basicPublishingCredentialsPolicies: [
      {
        allow: false
        name: 'scm'
      }
    ]
    appInsightResourceId: appInsight.outputs.resourceId
    storageAccountResourceId: storageAccount.outputs.resourceId
  }
}
