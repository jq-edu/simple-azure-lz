using './main.bicep'

param env = '<env>'
param spokeName = 'spoke-fctapp'
param location = 'canadacentral'

param storageConfig = {
  skuName: 'Standard_LRS'
  kind: 'StorageV2'
  supportsHttpsTrafficOnly: true
  minimumTlsVersion: 'TLS1_2'
}

param functionConfig = {
  skuName: 'Y1'
  siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'Java|17'
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 0
    }
}

