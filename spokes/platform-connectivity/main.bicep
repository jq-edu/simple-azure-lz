targetScope = 'subscription'

@description('Environment for the deployment.')
param env string

@description('Core name for the spoke.')
param spokeName string

@description('Provide the ID of the management group that you want to move the subscription to.')
param targetMgId string

@description('Provide the ID of the existing subscription for the hub.')
param subscriptionId string

@description('Location for all resources inherited from the deployment.')
param location string = deployment().location

@description('Configuration for the virtual network.')
param vnetConfig object

@description('Configuration for the virtual network.')
param bastionConfig object

@secure()
@description('Credentials for the virtual machine.')
param vmCredentials object

@description('Configuration for the virtual machine.')
param vmConfig object

// Resources names
var rgName = 'rg-${spokeName}-${env}'
var vnetName = 'vnet-${spokeName}-${env}'
var vmName = 'vm-${spokeName}-${env}'
var bastionName = 'bas-${spokeName}-${env}'
var pipBastionName = 'pip-${bastionName}'

resource moveSubscriptionToRightManagementGroup 'Microsoft.Management/managementGroups/subscriptions@2020-05-01' = {
  scope: tenant()
  name: '${targetMgId}/${subscriptionId}'
}

resource rg 'Microsoft.Resources/resourceGroups@2021-01-01' = {
  dependsOn: [
    moveSubscriptionToRightManagementGroup
  ]
  name: rgName
  location: location
}

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.5.1' = {
  name: 'deploy-${vnetName}'
  scope: rg
  params: {
    addressPrefixes: [
      vnetConfig.vnetAddressPrefix
    ]
    name: vnetName
    location: location
    subnets: vnetConfig.subnets
  }
}

module bastionHost 'br/public:avm/res/network/bastion-host:0.5.0' = {
  name: 'deploy-${bastionName}'
  scope: rg
  params: {
    name: bastionName
    virtualNetworkResourceId: virtualNetwork.outputs.resourceId
    location: location
    publicIPAddressObject: {
      allocationMethod: bastionConfig.pipConfig.allocationMethod
      name: pipBastionName
      // publicIPPrefixResourceId: ''
      skuName: bastionConfig.pipConfig.skuName
      skuTier: bastionConfig.pipConfig.skuTier
      zones: bastionConfig.pipConfig.zones
    }
    skuName: bastionConfig.skuName
  }
}

module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.10.0' = {
  name: 'deploy-${vmName}'
  scope: rg
  params: {
    adminUsername: vmCredentials.adminUsername
    adminPassword: vmCredentials.adminPassword
    imageReference: vmConfig.imageReference
    name: vmName
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            subnetResourceId: virtualNetwork.outputs.subnetResourceIds[0]
          }
        ]
        name: 'nic-${vmName}'
      }
    ]
    osDisk: vmConfig.osDisk
    osType: vmConfig.osType
    vmSize: vmConfig.vmSize
    computerName: vmConfig.computeName
    encryptionAtHost: false
    secureBootEnabled: true
    zone: 0
    autoShutdownConfig: vmConfig.autoShutdownConfig
  }
}
