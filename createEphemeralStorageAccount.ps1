   Param
    (
        [OutputType([string])]
        $storageOutput

    )
    try
    {
        $connectionName = 'AzureRunAsConnection'
        $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName

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
    $containerName = 'data'

    $storageAccount = New-AzureRmStorageAccount `
        -AccessTier Hot `
        -Kind BlobStorage `
        -Location $location `
        -Name $storageAccountName `
        -ResourceGroupName $resourceGroupName `
        -SkuName Standard_LRS

    $key = (Get-AzureRmStorageAccountKey -Name $storageAccountName -ResourceGroupName $resourceGroupName).Value[0]
    $context = New-AzureStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $key
    $container = New-AzureStorageContainer -Name $containerName -Context $context
    $expiryDate = (get-date).AddDays(2)
    $sasToken = New-AzureStorageContainerSASToken -Name $containerName -Context $context -ExpiryTime $expiryDate -FullUri

    $storageOutput = @{
    storageAccountName = $storageAccountName
    sasToken = $sasToken
    }

    Write-Output $storageOutput
