Write-Host "Installing packages..."
Install-Module Az.ManagementPartner

Write-Host "Connecting..."
Connect-AzAccount

Write-Host "Connected. Getting User's Tenants..."

$tenants = Get-AzTenant;

foreach ($tenant in $tenants) {
    Write-Host "Tenant:" $($tenant.Id) "-" $($tenant.Name)
}

$partnerMPN = $null
$tenantID = $null
$checked = $false
$haveOwner = $false
$haveContributor = $false
$haveReader = $false
$subscriptionsList = ""

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

Write-Host "Get Tenant's Subscriptions..."

$subscriptions = Get-AzSubscription -TenantId $tenantID

foreach ($subscription in $subscriptions) {
    
    $haveOwner = $false
    $haveContributor = $false
    $haveReader = $false
    
    Write-Host "Get Subscription ID" $($subscription.Id) "-" $($subscription.Name) "user's permissions..."
    
    # Perform operations on the subscription here
    $scope = "/subscriptions/" + $($subscription.Id)
    
    $context = Get-AzContext
    $userUpn = $context.Account.Upn

    $roleAssignments = Get-AzRoleAssignment -Scope $scope | Where-Object { $_.PrincipalName -eq $userUpn -and $_.RoleDefinitionName -eq "Owner" }

    if ($roleAssignments) {
        $haveOwner = $true
    }
    
    $roleAssignments = Get-AzRoleAssignment -Scope $scope | Where-Object { $_.PrincipalName -eq $userUpn -and $_.RoleDefinitionName -eq "Contributor" }

    if ($roleAssignments) {
        $haveContributor = $true
    }

    $roleAssignments = Get-AzRoleAssignment -Scope $scope | Where-Object { $_.PrincipalName -eq $userUpn -and $_.RoleDefinitionName -eq "Reader" }

    if ($roleAssignments) {
        $haveReader = $true
    }

    $subscriptionObject = [PSCustomObject] @{
        Subscription = ($subscription.Id) + " - " + ($subscription.Name)
        Owner = $haveOwner
        Contributor = $haveContributor
        Reader = $haveReader
    }

    # Write-Host "Subscription Object " $($subscriptionObject)
    $subscriptionsList += $($subscriptionObject)

}

$result.Subscriptions = $subscriptionsList

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