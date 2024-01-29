# ZWEI - Infrastructure

This is Bicep project.

## Steps

1. `Login-AzAccount -UseDeviceAuthentication`
1. `Select-AzSubscription -SubscriptionId 'b8d7fc1c-6003-4425-baf0-15d8db0e1714'`
1. `.\Projects\ServiceX\Deploy.ps1`

### Currently manual post-deployment steps

1. Select stack on app service
2. Enable diagnostics settings
3. Add managed identity to app service
