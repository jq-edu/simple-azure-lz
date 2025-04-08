$location = "canadacentral"
$deploymentName = "spoke-functionapp-$(Get-Date -Format yyyyMMddHHmm)"

az login
az account list -o table

az deployment sub create --location $location --name $deploymentName --template-file ./main.bicep --parameters .\main.bicepparam