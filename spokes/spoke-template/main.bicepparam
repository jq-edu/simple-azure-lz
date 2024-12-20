using './main.bicep'

param env = 'prod'
param spokeName = 'spoke-template'
param location = 'canadacentral'
param subscriptionId =  ''
param targetMgId =  ''

param vnetConfig = {
  hubVnet: {
    name: 'vnet-connectivity-prod'
    rgName: 'rg-connectivity-prod'
    subscriptionId: ''
  }
  vnetAddressPrefix: '10.2.1.0/24'
  subnets: [
    {
      name: 'main-subnet'
      addressPrefix:'10.2.1.0/26'
    }
  ]
}
