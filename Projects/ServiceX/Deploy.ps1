# How to deploy project

param(
    [Parameter()]
    [string]$Step
)

$Steps = @("network","logsAnalytics","appInsights","managedIdentity","keyvault")

function New-StepDeployment {
    param(
        [Parameter(Mandatory)]
        [string]$Step
    )
    Write-Host "Deploying: $Step..."
    New-AzResourceGroupDeployment -ResourceGroupName rg-ServiceX -TemplateFile $PSScriptRoot/Bicep/$Step.bicep -TemplateParameterFile $PSScriptRoot/Parameters/$Step.parameters.jsonc
}

New-AzResourceGroup -Name rg-ServiceX -Location eastus -Force

if ($Step -eq "") {
    Write-Host "Deploying all steps..."
    foreach ($Step in $Steps) {
        New-StepDeployment -Step $Step
    }
} else {
    if ($Steps -contains $Step) {
        Write-Host "Deploying $Step"
    } else {
        Write-Host "Step $Step not found"
        exit
    }
    New-StepDeployment -Step $Step
}
