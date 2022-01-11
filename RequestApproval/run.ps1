using namespace System.Net
param($Request, $TriggerMetadata)

"Requesting Approval, please answer!"

$ID = $Request.instanceId
$FunctionURL = $Request.RequestUrl
$StorageAccountName = $Request.StorageAccountName
$FunctionURL = $FunctionURL.split('?')[0]

$ApproveURL = $FunctionURL -replace "orchestrators/SmacOrchestrator", "ApproveRemediate?InstanceId=$ID"

"ApproveURL ="+$ApproveURL