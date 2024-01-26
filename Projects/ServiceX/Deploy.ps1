# How to deploy project

New-AzResourceGroup -Name rg-ServiceX -Location eastus -Force
New-AzResourceGroupDeployment -Verbose -ResourceGroupName rg-ServiceX -TemplateFile $PSScriptRoot/Bicep/network.bicep -TemplateParameterFile $PSScriptRoot/Parameters/network.parameters.jsonc
