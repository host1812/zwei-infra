param serviceName string = 'servicex'
param location string

module component '../../../bicep-registry-modules/modules/app/app-configuration/main.bicep' = {
  name: 'appConfig--${uniqueString(deployment().name, location)}-${serviceName}-${location}'
  params: {
    location: location
    name: 'appc-${serviceName}-${location}'
  }
}
