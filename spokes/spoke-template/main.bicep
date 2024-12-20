targetScope = 'subscription'

@description('Environment for the deployment.')
param env string

@description('Core name for the spoke.')
param spokeName string

@description('Location for all resources inherited from the deployment.')
param location string = deployment().location

@description('Provide the ID of the management group that you want to move the subscription to.')
param targetMgId string

@description('Provide the ID of the existing subscription for the hub.')
param subscriptionId string

param vnetConfig object

var rgName = 'rg-${spokeName}-${env}'
var vnetName = 'vnet-${spokeName}-${env}'

resource hubVnet 'Microsoft.Network/virtualNetworks@2024-03-01' existing = {
  name: vnetConfig.hubVnet.name
  scope: resourceGroup(vnetConfig.hubVnet.subscriptionId, vnetConfig.hubVnet.rgName)
}

resource moveSubscriptionToRightManagementGroup 'Microsoft.Management/managementGroups/subscriptions@2020-05-01' = {
  scope: tenant()
  name: '${targetMgId}/${subscriptionId}'
}

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  name: rgName
  location: location
}

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.5.1' = {
  name: 'virtualNetworkDeployment'
  scope: rg
  params: {
    addressPrefixes: [
      vnetConfig.vnetAddressPrefix
    ]
    name: vnetName
    subnets: vnetConfig.subnets
    peerings: [
      {
        name: '${spokeName}-to-hub'
        allowForwardedTraffic: true
        allowGatewayTransit: false
        allowVirtualNetworkAccess: true
        remotePeeringAllowForwardedTraffic: false
        remotePeeringAllowVirtualNetworkAccess: true
        remotePeeringEnabled: true
        remotePeeringName: 'hub-to-${spokeName}'
        remoteVirtualNetworkResourceId: hubVnet.id
        useRemoteGateways: false
      }
    ]
  }
}
