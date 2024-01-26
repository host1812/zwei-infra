param serviceName string = 'servicex'
param location string

resource analyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: 'law-${serviceName}-${location}'
}

module component '../../../ResourceModules/modules/insights/component/main.bicep' = {
  name: 'appInsights--${uniqueString(deployment().name, location)}-${serviceName}-${location}'
  params: {
    location: location
    name: 'appi-${serviceName}-${location}'
    workspaceResourceId: analyticsWorkspace.id
  }
}
