param serviceName string = 'servicex'
param location string

module virtualNetwork '../../../bicep-registry-modules/modules/network/virtual-network/main.bicep' = {
  name: 'virtualNetwork--${location}'
  params: {
    name: 'vnet-${serviceName}-${location}'
    location: location
    addressPrefixes: [
      '10.0.0.0/16'
    ]
    subnets: [
      {
        name: '${serviceName}-main'
        addressPrefix: '10.0.2.0/24'
      }
    ]
  }
}
