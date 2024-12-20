$location = "canadacentral"
$deploymentName = "platform-connectivity-dev-$(Get-Date -Format yyyyMMddHHmm)"

az login

az deployment sub create --location $location --name $deploymentName --template-file ./main.bicep --parameters .\main.<env>.bicepparam