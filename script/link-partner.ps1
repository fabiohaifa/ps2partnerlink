Write-Host "Installing packages..."
Install-Module Az.ManagementPartner

Write-Host "Connecting..."
Connect-AzAccount

$partnerMPN = $null

$checkID = $false

do {
    $partnerMPN = Read-Host "Inform the Partner MPN ID"

    if (![System.Int32]::TryParse($partnerMPN, [ref]$null)) {
        Write-Host "Invalid Partner MPN ID."
    } else {
        $checkID = $true
    }
} until ($checkID)

$result = New-Object System.Collections.ArrayList

Write-Host "Get user associated Tennants..."
$tennants = Get-AzTenant;

foreach ($tennant in $tennants) {

    $myObject = [PSCustomObject] @{
        Tennant = ""
        PAL = ""
        Subscriptions = New-Object System.Collections.ArrayList
    }

    $myObject.Tennant = $($tennant.Id) + " - " + $($tennant.Name)

    Write-Host "Get Tennat's Subscriptions..."

    $subscriptionsList = New-Object System.Collections.ArrayList

    $subscriptions = Get-AzSubscription -TenantId $($tennant.Id)

    foreach ($subscription in $subscriptions) {
        Write-Host "Get Subscription ID " + $($subscription.Id) + " permissions..."
     
        # Perform operations on the subscription here
        $scope = "/subscriptions/" + $($subscription.Id)
        $roleAssignments = Get-AzRoleAssignment -Scope $scope

        $subscriptionObject = [PSCustomObject] @{
            Subscription = ($subscription.Id) + " - " + ($subscription.Name)
            UserPermissions = $roleAssignments
        }

        $subscriptionsList.Add($subscriptionObject)

    }

    $myObject.Subscriptions = $subscriptionsList

    # Connecting in the current Tennant
    Connect-AzAccount -TenantId $($tennant.Id)

    # Check if the tennant already has the Partner MPN ID:
    $existsMPNID = Get-AzManagementPartner

    if ($existsMPNID.Id -eq $null) {
        #Update-AzManagementPartner -PartnerId $partnerMPN -TenantId $($tennant.Id)    
        $myObject.PAL = "Status: Registered"
    } elseif (!$existsMPNID.Id -eq $partnerMPN) {
        $myObject.PAL = "Status: Other MPN ID"
    } else {
        $myObject.PAL = "Status: Already registered"
    }

    $result.Add($myObject)

}

Write-Host $result
