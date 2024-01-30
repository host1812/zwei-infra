@sys.description('''
The 'base' name; used when creating resource(s).
`app-{baseName}`
''')
param baseName string

@sys.description('''
The location in which the resource(s) will be created.
''')
param location string

@sys.description('''
Health check URL for the web app.
''')
param healthCheckPath string = '/'
param appServiceProperties object = {}

param linuxFxVersion string = ''

@sys.description('''
The identity for the virtual machine scale set.
```
{
  type: string (one of `['None', 'SystemAssigned', 'SystemAssigned, UserAssigned', 'UserAssigned'`)
  userAssignedIdentities: object[{
    id: string
    principalId: string
    clientId: string
  }]
}
```
''')
param identity object = {}

param acrManagedIdentityClientId string = ''

@sys.description('''
Diagnostic settings to apply to the MySQL Flexible Server instance.
```
{
  enabled: bool
  logs: object[{
    category: string
    enabled: bool
    retentionPolicy: {
      days: int
      enabled: bool
    }
  }]
  metrics: object[{
    category: string
    enabled: bool
    retentionPolicy: {
      days: int
      enabled: bool
    }
    timeGrain: string
  }]
  storageAccountId: string
  workspaceId: string
}
```
''')
param diagnosticSettings object = {
  enabled: false
}

@sys.description('''
Enables zone redundancy for the App Service Plan. This is inmutable property and can't be changed after the App Service Plan is created.
''')
param zoneRedundant bool = false

@sys.description('''
Allows to control if we want to scale each web app individually or scale all of them together.
If enabled, numberOfWorkers in web site defines instance count for each web app.
''')
param perSiteScaling bool = false

@sys.description('''
Kind for App Service Plan.
''')
@allowed([
  'windows'
  'linux'
])
param kind string = 'linux'

@sys.description('''
The identity for the virtual machine scale set.
```
{
  name: string
  tier: string
  capacity: int
}
```
''')
param sku object = {}

param netFrameworkVersion string = ''
param use32BitWorkerProcess bool = false

resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: 'asp-${baseName}'
  location: location
  properties: {
    reserved: kind == 'linux' ? true : false // according to documentation, should be false for windows, true for linux
    zoneRedundant: zoneRedundant
    perSiteScaling: perSiteScaling
  }
  sku: sku
  kind: 'app' // Should be app for both windows and linux
}

resource appService 'Microsoft.Web/sites@2022-03-01' = {
  name: 'app-${baseName}'
  location: location
  kind: 'app'
  identity: (empty(identity) ? null : {
    type: identity.type
    userAssignedIdentities: (!contains(identity, 'userAssignedIdentities') || empty(identity.userAssignedIdentities) ? null : reduce(identity.userAssignedIdentities, {}, (x, y) => union(x, { '${y.id}': {} })))
  })
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true // Not exposed to prevent turning on
    siteConfig: {
      // Metadata is used as payload to set dotnet Windows stack in Azure Portal. Details: https://github.com/Azure/bicep/issues/3314.
      // Disabling warning, because bicep doesn't support metadata in site config object.
      #disable-next-line BCP037
      metadata: kind == 'windows' ? [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ] : null
      use32BitWorkerProcess: use32BitWorkerProcess
      netFrameworkVersion: !empty(netFrameworkVersion) ? netFrameworkVersion : null
      linuxFxVersion: !empty(linuxFxVersion) ? linuxFxVersion : null
      healthCheckPath: healthCheckPath
      ftpsState: 'Disabled' // Enfoced to prevent from turning on anywhere
      acrUseManagedIdentityCreds: !empty(acrManagedIdentityClientId) ? true : false
      acrUserManagedIdentityID: !empty(acrManagedIdentityClientId) ? acrManagedIdentityClientId : null
      cors: {
        allowedOrigins: [
          '*'
        ]
      }
      alwaysOn: true
      detailedErrorLoggingEnabled: true
    }
  }
}

resource appServiceSettings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'appsettings'
  kind: 'string'
  parent: appService
  properties: appServiceProperties
}

resource appServiceDiagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (diagnosticSettings.enabled) {
  name: 'diag-${appService.name}'
  scope: appService
  properties: {
    logs: contains(diagnosticSettings, 'logs') ? diagnosticSettings.logs : []
    metrics: contains(diagnosticSettings, 'metrics') ? diagnosticSettings.metrics : []
    storageAccountId: contains(diagnosticSettings, 'storageAccountId') ? diagnosticSettings.storageAccountId : null
    workspaceId: contains(diagnosticSettings, 'workspaceId') ? diagnosticSettings.workspaceId : null
  }
}

output siteName string = appService.name
