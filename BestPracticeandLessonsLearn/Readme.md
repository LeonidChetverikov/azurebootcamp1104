
# Best Practices for Azure Automation

Below are two examples of Azure automation that include best practices. These examples show you how to automate routine tasks — such as starting/stopping virtual machines and updating them. Both examples focus on security, maintainability, and error handling.

---

## Example 1: Automated VM Start/Stop Runbook

**Scenario:**  
Automate the process of starting VMs in the morning and stopping them at night to reduce costs. This is especially useful in non-production environments or if you have scheduled workloads.

**Key Best Practices:**

- **Use Run As Accounts or Managed Identities:**  
  Avoid interactive authentication. Use a non-interactive authentication approach so that your runbooks run reliably.
- **Parameterize Runbooks:**  
  Make the runbook take parameters (resource group, VM name etc) to make it reusable.
- **Implement Robust Error Handling:**  
  Use `try/catch` blocks and ensure messages are logged while avoiding output that exceeds allowed limits.
- **Schedule Runs through Azure Automation:**  
  Instead of invoking manually, run the runbook during off-peak times.

### Sample Runbook (PowerShell)

```powershell
<#
.SYNOPSIS
    Starts or stops an Azure Virtual Machine based on a provided action.
.DESCRIPTION
    This runbook accepts the resource group name, VM name, and an action parameter (Start/Stop).
    It uses a non-interactive authentication method (via an Automation Run As Account) to perform the task.
.PARAMETER ResourceGroupName
    The name of the resource group containing the Virtual Machine.
.PARAMETER VMName
    The name of the Virtual Machine to manage.
.PARAMETER Action
    The action to perform on the VM: 'start' or 'stop'.
.NOTES
    Ensure your Automation Run As account or Managed Identity has sufficient permissions.
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $true)]
    [string]$VMName,

    [Parameter(Mandatory = $true)]
    [ValidateSet("start", "stop")]
    [string]$Action
)

try {
    # Use Run As Account for non-interactive authentication
    $connectionName = "AzureRunAsConnection"
    $servicePrincipalConnection = Get-AutomationConnection -Name $connectionName
    Connect-AzAccount -ServicePrincipal `
                      -Tenant $servicePrincipalConnection.TenantId `
                      -ApplicationId $servicePrincipalConnection.ApplicationId `
                      -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint `
                      -ErrorAction Stop

    Write-Output "Authenticated successfully using the Automation Run As Account."

    if ($Action -eq "start") {
        Write-Output "Starting VM '$VMName' in resource group '$ResourceGroupName'..."
        Start-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName -ErrorAction Stop
        Write-Output "VM '$VMName' started successfully."
    }
    elseif ($Action -eq "stop") {
        Write-Output "Stopping VM '$VMName' in resource group '$ResourceGroupName'..."
        Stop-AzVM -Name $VMName -ResourceGroupName $ResourceGroupName -Force -ErrorAction Stop
        Write-Output "VM '$VMName' stopped successfully."
    }
}
catch {
    $errorMessage = $_.Exception.Message
    if ($errorMessage.Length -gt 512) {
        $errorMessage = $errorMessage.Substring(0, 512)
    }
    Write-Error "An error occurred while performing the action '$Action' on VM '$VMName'. Details: $errorMessage"
}
```

### What we Learn

- **Authentication Matters:**  
  Use of the Run As account or managed identity prevents login issues.
- **Scheduling Saves Costs:**  
  Automatic powering off of virtual machines reduces costs and helps enforce good governance.
- **Logging and Error Management:**  
  Truncating long error messages avoids logging quota problems in Automation.

---

## Example 2: Automating Updates with Patch Management

**Scenario:**  
Simplify the patch management process for a collection of Azure VMs by integrating Azure Update Management with Automation runbooks. This minimizes downtime and removes errors associated with manual patch deployments.

**Key Best Practices:**

- **Integrate with Azure Monitor and Log Analytics:**  
  Track compliance and obtain comprehensive patch status reports.
- **Use Declarative Templates:**  
  Schedule updates transparently so that you can monitor changes with Infrastructure-as-Code practices.
- **Limit Permissions:**  
  Grant only the necessary permissions to the Automation account or identity that is carrying out these tasks.
- **Monitor and Alert:**  
  Create alert rules that notify the relevant teams when patches fail or when remediation activities need to be taken.

### Workflow Outline

- **Schedule Deployment:**  
  Schedule a patch deployment time with Azure Update Management.
- **Pre-Patch Validation:**  
  Perform a simple check to ensure the VMs are functioning properly and not dealing with critical tasks.
- **Patch Deployment:**  
  Use the Update Management solution and Automation to deploy patches.
- **Post-Patch Validation:**  
  Run another runbook to check the patch status and report any issues.

### Simplified Runbook Snippet for Patch Management

```powershell
<#
.SYNOPSIS
    Initiates an Azure Update Management deployment.
.DESCRIPTION
    This runbook triggers a scheduled update deployment for target machines.
    It uses Automation’s integration with Update Management in Log Analytics.
.PARAMETER WorkspaceId
    The Log Analytics workspace ID used by Update Management.
.PARAMETER DeploymentName
    A name for this patch deployment job.
.NOTES
    Ensure your Automation account has access to the Log Analytics workspace.
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$WorkspaceId,

    [Parameter(Mandatory = $true)]
    [string]$DeploymentName
)

try {
    Write-Output "Triggering update deployment '$DeploymentName' for workspace '$WorkspaceId'..."
    
    Invoke-AzOperationalInsightsQuery `
        -WorkspaceId $WorkspaceId `
        -Query "AzureActivity | where CategoryValue=='Update'" | Out-Null

    Write-Output "Update deployment '$DeploymentName' triggered successfully."
}
catch {
    $errorMessage = $_.Exception.Message
    if ($errorMessage.Length -gt 512) {
        $errorMessage = $errorMessage.Substring(0, 512)
    }
    Write-Error "Failed to trigger update deployment '$DeploymentName'. Details: $errorMessage"
}
```

### What we Learn

- **Automation Reduces Manual Intervention:**  
  Automating patch management prevents human error and ensures timely updates.
- **Visibility Is Critical:**  
  Integration with Log Analytics and monitoring tools helps in tracking deployment progress and troubleshooting issues faster.
- **Iterative Improvement:**  
  Patch deployment feedback can assist in making schedules more optimal, refining the way we manage errors, and altering maintenance schedules.

---

## Summary 

- **Non-Interactive Authentication:**  
  Use Run As accounts or managed identities to avoid interactive login issues.
- **Error Handling:**  
  Always limit log output and handle exceptions gracefully.
- **Minimal Permissions:**  
  Follow the principle of least privilege to secure your automation processes.
- **Parameterized and Reusable Runbooks:**  
  Make runbooks flexible with parameters to allow support for different conditions. 
- **Monitoring and Alerts:**  
  Integration with logging, monitoring, and alerting (using tools like Log Analytics and Azure Monitor) is also crucial for operational excellence.
- **Iterative Improvements:**  
  Learn from each deployment—whether it’s VM management or patching—to continually refine your automation playbook.

For further details, please refer to [Azure Automation Security Guidelines](https://learn.microsoft.com/en-us/azure/automation/automation-security-guidelines) and [Well-Architected Framework Recommendations on Automation](https://learn.microsoft.com/en-us/azure/well-architected/operational-excellence/automate-tasks).

---
