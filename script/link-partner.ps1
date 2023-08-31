Write-Host "Installing packages..."
Install-Module Az.ManagementPartner

Write-Host "Connecting..."
Connect-AzAccount -UseDeviceAuthentication

Write-Host "Connected. Getting User's Tenants..."

$tenants = Get-AzTenant;

foreach ($tenant in $tenants) {
    Write-Host "Tenant:" $($tenant.Id) "-" $($tenant.Name)
}

$partnerMPN = $null
$tenantID = $null
$checked = $false

do {
    $partnerMPN = Read-Host "Inform the Partner MPN ID"

    if (![System.Int32]::TryParse($partnerMPN, [ref]$null)) {
        Write-Host "Invalid Partner MPN ID."
    } else {
        $checked = $true
    }
} until ($checked)

$checked = $false
do {
    $tenantID = Read-Host "Inform the Tenant ID"

    if (!($tenantID -match "^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$")) {
        Write-Host "Invalid Tenant ID."
    } else {
        $checked = $true
    }
} until ($checked)

$result = [PSCustomObject] @{
    Tennant = $($tenantID)
    PAL = ""
    Subscriptions = ""
}

# Connecting in the current Tennant for trying change the MPN ID
Write-Host "Connecting on Tenant " $($tenantID) "..."
Connect-AzAccount -TenantId $($tenantID)

Write-Host "Get Tennat's Subscriptions..."

$subscriptionsList = @()

$subscriptions = Get-AzSubscription -TenantId $tenantID

foreach ($subscription in $subscriptions) {
    Write-Host "Get Subscription ID" $($subscription.Id) "-" $($subscription.Name) "permissions..."
    
    $userPermissions = ""

    # Perform operations on the subscription here
    $scope = "/subscriptions/" + $($subscription.Id)
    $roleAssignments = Get-AzRoleAssignment -Scope $scope

    foreach($ra in $roleAssignments) {
        $userPermissions += "[Scope: " + $ra.Scope + " Display Name: " + $ra.Display + " , Definition Name: " + $ra.RoleDefinitionName + " ]"
        Write-Host "Permissions: " $($userPermissions)
    }

    $subscriptionObject = [PSCustomObject] @{
        Subscription = ($subscription.Id) + " - " + ($subscription.Name)
        UserPermissions = $userPermissions
    }

    Write-Host "Subscription Object " $($subscriptionObject)
    $subscriptionsList += $subscriptionObject

}

Write-Host "Subscription List " $($subscriptionsList -join ",")
$result.Subscriptions = $subscriptionsList -join ","

# Check if the tennant already has the Partner MPN ID:
try {
    New-AzManagementPartner -PartnerId $partnerMPN -WhatIf
    $result.PAL = "Status: Registered"
}
catch {
    Update-AzManagementPartner -PartnerId $partnerMPN -WhatIf
    $result.PAL = "Status: Already registered, updated"
}
    
Write-Host "Printing results..."
Write-Host $result