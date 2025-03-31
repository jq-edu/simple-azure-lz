<#
.SYNOPSIS
This script is designed to shut down all Fabric Capacities in a development subscription.

.DESCRIPTION
The script iterates through all Fabric Capacities within a specified development subscription and performs a pause operation on each unit. This is useful for managing resources and reducing costs in a development environment when the Fabric Units are not in use.

.PARAMETER SubscriptionId
The ID of the Azure subscription where the Fabric Units are located.

.NOTES
- Ensure you have the necessary permissions to manage Fabric Units in the subscription.
- Verify the subscription ID and environment before running the script to avoid unintended shutdowns.

#>
param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId
)

if (-not $env:AZUREPS_HOST_ENVIRONMENT) {
    "Running Locally (Interactively)"
    az login
} else {
    "Running in Azure Automation"
    az login --identity
}

# Set the subscription context to the specified subscription ID
az account set --subscription $SubscriptionId

# Make sure the Fabric az extention is loaded
az extension add --name microsoft-fabric --upgrade --yes

# get list of all Fabric Capacities in the subscription
$capacities = az fabric capacity list | ConvertFrom-Json

"Found $($capacities.Count) Fabric Capacities in subscription $SubscriptionId."
foreach ($capacity in $capacities) {
    $capacityName = $capacity.name
    $capacityRG = $capacity.resourceGroup
    $capacitystate = $capacity.state
    "Fabric Capacity: $capacityName in resource group $capacityRG is in state $capacitystate."
    if ($capacitystate -eq "Active") {
        "Pausing Fabric Capacity: $capacityName..."
        az fabric capacity suspend --capacity-name $capacityName --resource-group $capacityRG
        "Fabric Capacity: $capacityName has been paused."
    } else {
        "Fabric Capacity: $capacityName is already in a non-running state. Skipping..."
    }
}