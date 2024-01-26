param serviceName string = 'servicex'
param location string

resource analyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: 'law-${serviceName}-${location}'
}

module serverFarm '../../../ResourceModules/modules/web/serverfarm/main.bicep' = {
  name: 'serverFarms--${uniqueString(deployment().name, location)}-${serviceName}-${location}'
  params: {
    name: 'asp-${serviceName}-${location}'
    location: location
    sku: {
      name: 'S1'
    }

  }
}

module webApp '../../../ResourceModules/modules/web/site/main.bicep' = {
  name: 'webSite--${uniqueString(deployment().name, location)}-${serviceName}-${location}'
  params: {
    name: 'app-${serviceName}-${location}'
    location: location
    kind: 'app'
    serverFarmResourceId: serverFarm.outputs.resourceId
  }
}
