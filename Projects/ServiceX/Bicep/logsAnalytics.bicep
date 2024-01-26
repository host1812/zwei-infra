param serviceName string = 'servicex'
param location string

module logsAnalytics '../../../ResourceModules/modules/operational-insights/workspace/main.bicep' = {
  name: 'logsAnalytics--${location}'
  params: {
    name: 'law-${serviceName}-${location}'
    location: location
  }
}
