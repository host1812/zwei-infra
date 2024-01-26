param serviceName string = 'servicex'
param location string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' existing = {
  name: 'mi-${serviceName}-${location}'
}

module keyVault '../../../bicep-registry-modules/modules/security/keyvault/main.bicep' = {
  name: 'keyvault--${uniqueString(deployment().name, location)}-${serviceName}-${location}'
  params: {
    location: location
    name: 'kv-${serviceName}-${location}'
    rbacPolicies: [
      {
        objectId: managedIdentity.properties.principalId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
          ]
          certificates: [
            'get'
            'list'
            'set'
          ]
        }
      }
    ]
  }
}
