function Create-EphemeralStorageAccount
(
    [Parameter(Mandatory=$true)]
    [String]
    $automationAccountName
)
{
    $location = Get-AzureAutomationVariable `
        -AutomationAccountName $automationAccountName `
        -Name 'location'

    $resourceGroupName = Get-AzureAutomationVariable `
        -AutomationAccountName $automationAccountName `
        -Name 'resourceGroupName'

    $subscriptionId = Get-AzureAutomationVariable `
        -AutomationAccountName $automationAccountName `
        -Name 'subscriptionId'

    $storageAccountName = 'datadrop{0:yyyyMMddhhmmss}' `
        -f [System.DateTime]::UtcNow

    Get-AzureRmSubscription -SubscriptionId $subscriptionId | Select-AzureRmSubscription

    $storageAccount = New-AzureRmStorageAccount `
        -AccessTier Hot `
        -Kind BlobStorage `
        -Location $location `
        -Name $storageAccountName `
        -ResourceGroupName $resourceGroupName `
        -SkuName Standard_LRS

    Write-Output –InputObject $storageAccount
}

Create-EphemeralStorageAccount `
    -automationAccountName vmsetup
