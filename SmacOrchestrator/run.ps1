param($Context, $TriggerMetadata)

Invoke-DurableActivity -FunctionName "Audit"
$instanceId = $TriggerMetadata.Context.instanceId

$duration = New-TimeSpan -Seconds 300
$Object = [PSCustomObject]@{
    instanceID         = $instanceId
    RequestUrl         = $Context.Input
}
"InstanceID = "+$instanceId
"Context.Input = "+$Context.Input
Invoke-DurableActivity -FunctionName "RequestApproval" -Input $Object

$durableTimeoutEvent = Start-DurableTimer -Duration $duration -NoWait
$approvalEvent = Start-DurableExternalEventListener -EventName "ApprovalEvent" -NoWait

$firstEvent = Wait-DurableTask -Task @($approvalEvent, $durableTimeoutEvent) -Any

if ($approvalEvent -eq $firstEvent) {
    Stop-DurableTimerTask -Task $durableTimeoutEvent
    "Approved. Calling remediate..."
    Invoke-DurableActivity -FunctionName "Remediate"
}
else {
    "Not receive approval status. timeout"
}
