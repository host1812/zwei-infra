@minLength(3)
param serviceName string = 'servicex'

param location string

module virtualNetwork '../../../bicep-registry-modules/modules/identity/user-assigned-identity/main.bicep' = {
  name: 'managedIdentity--${uniqueString(deployment().name, location)}-${serviceName}-${location}'
  params: {
    name: 'mi-${serviceName}-${location}'
    location: location
  }
}
