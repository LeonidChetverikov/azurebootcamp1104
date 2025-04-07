<#
.SYNOPSIS
    Starts an Azure Virtual Machine using a Managed Identity.
.DESCRIPTION
    This runbook accepts a ResourceGroupName and VMName and starts the specified Virtual Machine.
.PARAMETER ResourceGroupName
    The name of the resource group containing the Virtual Machine.
.PARAMETER VMName
    The name of the Virtual Machine to start.
.NOTES
    Ensure that the Automation Account's managed identity has proper access to start VMs.
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $true)]
    [string]$VMName
)

try {
    # Authenticate using the Managed Identity
    Connect-AzAccount -Identity -ErrorAction Stop

    Write-Output "Authenticated successfully using the Managed Identity."

    Write-Output "Attempting to start VM '$VMName' in resource group '$ResourceGroupName'..."

    # Start the Virtual Machine
    Start-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName -ErrorAction Stop

    Write-Output "The Virtual Machine '$VMName' has been started successfully."
}
catch {
    $errorMessage = $_.Exception.Message
    if ($errorMessage.Length -gt 512) {
        $errorMessage = $errorMessage.Substring(0, 512)
    }
    Write-Error "An error occurred while starting the Virtual Machine '$VMName'. Details: $errorMessage"
}
