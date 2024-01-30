param serviceName string = 'servicex'
param location string

// resource analyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
//   name: 'law-${serviceName}-${location}'
// }

// module serverFarm '../../../ResourceModules/modules/web/serverfarm/main.bicep' = {
//   name: 'serverFarms--${uniqueString(deployment().name, location)}-${serviceName}-${location}'
//   params: {
//     name: 'asp-${serviceName}-${location}'
//     location: location
//     sku: {
//       name: 'S1'
//     }

//   }
// }

// module webApp '../../../ResourceModules/modules/web/site/main.bicep' = {
//   name: 'webSite--${uniqueString(deployment().name, location)}-${serviceName}-${location}'
//   params: {
//     name: 'app-${serviceName}-${location}'
//     location: location
//     kind: 'app'
//     serverFarmResourceId: serverFarm.outputs.resourceId
//   }
// }

// Diagnostic settings
param diagnosticSettingsLogCategories array = [
  'AppServiceHTTPLogs'
  'AppServiceConsoleLogs'
  'AppServiceAppLogs'
  'AppServiceAuditLogs'
  'AppServicePlatformLogs'
]

param diagnosticSettingsMetricCategories array = [
  'AllMetrics'
]

// Scaling settings
param zoneRedundant bool = false
param capacity int = 1
param perSiteScaling bool = false

// @sys.description('''
// A list of user assigned identities to associated with the VM's in the VMSS.
// ```
// [
//   {
//     name: string
//     resourceGroupName: string (optional)
//     subscriptionId: string(optional)
//   }
// ]
// ```
// ''')
// param userAssignedIdentities array = []

module appService 'modules/appService@1/main.bicep' = {
  name: '${serviceName}-${location}'
  params: {
    baseName: '${serviceName}-${location}'
    location: location
    netFrameworkVersion: 'v8.0'
    sku: {
      name: 'S1'
      tier: 'Standard'
      size: 'S1'
      family: 'S'
      capacity: capacity
    }
    kind: 'windows'
    zoneRedundant: zoneRedundant
    perSiteScaling: perSiteScaling
    healthCheckPath: '/'
    diagnosticSettings: {
      enabled: !empty(diagnosticSettingsLogCategories) || !empty(diagnosticSettingsMetricCategories)
      logs: [for _logCategory in diagnosticSettingsLogCategories: {
        category: _logCategory
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }]
      metrics: [for _metricCategory in diagnosticSettingsMetricCategories: {
        category: _metricCategory
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }]
      // workspaceId: analyticsWorkspace.id
    }
    appServiceProperties: {

      // This is minimal configuration needed for VGSputnik injected.
      // All other properties will come from app config (including secrets).
      // Example: https://appcs-vgdev.azconfig.io
      SERVICEX_APPCONFIG__URI: 'https://appcs-${serviceName}.azconfig.io/'
      SERVICEX_APPCONFIG__LABEL: 'servicex'

      // Take first identity as a default.
      AZURE_CLIENT_ID: 'XX-YY'
    }
  }
}
