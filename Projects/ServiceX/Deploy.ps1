# How to deploy project

New-AzResourceGroup -Name rg-ServiceX -Location eastus
New-AzResourceGroupDeployment -ResourceGroupName rg-ServiceX -TemplateFile Bicep/network.bicep -ParameterFile ./Parameters/network.parameters.json
