
Write-Host "Connecting..."
Connect-AzAccount

$context = Get-AzContext
$userEmail = $context.Account.Id
$partnerMPN = $null

$checkID = $false

do {
    $partnerMPN = Read-Host "Inform the Partner MPN ID:"

    if (![System.Int32]::TryParse($partnerMPN, [ref]$null)) {
        Write-Host "Invalid Partner MPN ID."
    } else {
        $checkID = $true
    }
} until ($checkID)

$result = New-Object System.Collections.ArrayList

Write-Host "Get user associated Tennants..."
$tennants = Get-AzTenant;

$myObject = [PSCustomObject] @{
    Tennant = ""
    PAL = ""
    Subscriptions = New-Object System.Collections.ArrayList
}

foreach ($tennant in $tennants) {

    $myObject.Tennant = $($tennant.Id) - $($tennant.Name)

    Write-Host "Get Tennat's Subscriptions..."

    $subscriptionObject = [PSCustomObject] @{
        Subscription = ""
        UserPermissions = Array.Empty
    }

    $subscriptions = Get-AzSubscription -TenantId $($tennant.Id)

    foreach ($subscription in $subscriptions) {
        Write-Host "Get Subscription permissions..."
     
        # Perform operations on the subscription here
        $roleAssignments = Get-AzRoleAssignment -Scope "/subscriptions/" + $($subscription.Id) -SignInName $userEmail

        $subscriptionObject.Subscription = ($subscription.Id) + " - " + ($subscription.Name)
        $subscriptionObject.UserPermissions = $roleAssignments

    }

    $myObject.Subscriptions = $subscriptionObject

    # Check if the tennant already has the Partner MPN ID:
    $existsMPNID = Get-AzManagementPartner -TenantId $($tennant.Id) -ErrorAction SilentlyContinue

    if ($existsMPNID.Id -eq $null) {
        Update-AzManagementPartner -PartnerId $partnerMPN -TenantId $($tennant.Id)    
        $myObject.PAL = "Status: Registered"
    } elseif (!$existsMPNID.Id -eq $partnerMPN) {
        $myObject.PAL = "Status: Other MPN ID"
    } else {
        $myObject.PAL = "Status: Already registered"
    }

    $myArrayList.Add($myObject)

}

Write-Host $result
