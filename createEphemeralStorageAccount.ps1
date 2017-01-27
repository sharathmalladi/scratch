try
{
    $servicePrincipalConnection = Get-AutomationConnection -Name 'AzureRunAsConnection'

    Add-AzureRmAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint

    Write-Output "Successfully logged in to Azure." 
}
catch
{
    if (!$servicePrincipalConnection) 
    { 
        $ErrorMessage = "Connection $connectionName not found." 
        throw $ErrorMessage 
    }  
    else 
    { 
        Write-Error -Message $_.Exception 
        throw $_.Exception 
    } 
}

Select-AzureRmSubscription -SubscriptionId $servicePrincipalConnection.SubscriptionID

$location = Get-AutomationVariable -Name 'location'
$resourceGroupName = Get-AutomationVariable -Name 'resourceGroupName'

$storageAccountName = 'datadrop{0:yyyyMMddhhmmss}' -f [System.DateTime]::UtcNow

$storageAccount = New-AzureRmStorageAccount `
    -AccessTier Hot `
    -Kind BlobStorage `
    -Location $location `
    -Name $storageAccountName `
    -ResourceGroupName $resourceGroupName `
    -SkuName Standard_LRS

Write-Output -InputObject $storageAccount.Name
