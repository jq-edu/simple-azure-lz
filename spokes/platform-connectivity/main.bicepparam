using './main.bicep'

param env = 'prod'
param spokeName = 'connectivity'
param location = 'canadacentral'
param subscriptionId =  ''
param targetMgId =  ''

param vnetConfig = {
  vnetAddressPrefix: '10.0.0.0/16'
  subnets: [
    {
      name: 'vm-subnet'
      addressPrefix:'10.0.1.0/24'
    }
    {
      name: 'AzureBastionSubnet'
      addressPrefix:'10.0.9.0/24'
    }
  ]
}

param bastionConfig = {
  skuName: 'Basic'
  pipConfig: {
    allocationMethod: 'Static'
    skuName: 'Standard'
    skuTier: 'Regional'
    zones: [
      1
    ]
  }
}

@secure()
param vmCredentials = {
  adminUsername: ''
  adminPassword: ''
}

param vmConfig = {
  imageReference: {
    offer: 'WindowsServer'
    publisher: 'MicrosoftWindowsServer'
    sku: '2022-datacenter-azure-edition'
    version: 'latest'
  }
  osDisk: {
    caching: 'ReadWrite'
    diskSizeGB: 128
    managedDisk: {
      storageAccountType: 'Standard_LRS'
    }
  }
  osType: 'Windows'
  vmSize: 'Standard_D2s_v3'
  computeName: 'winvm1'
  autoShutdownConfig: {
    dailyRecurrenceTime: '18:00'
    status: 'Enabled'
    timeZone: 'Eastern Standard Time'
  }
}

