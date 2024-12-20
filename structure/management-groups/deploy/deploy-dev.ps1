$location = "canadacentral"
$deploymentName = "structure-mgmt-group-$(Get-Date -Format "yyyyMMddHHmm")"

az login

# la première fois on doit se donner accès au root management group
# az role assignment create --assignee "user@tenant.onmicrosoft.com" --scope "/" --role "Owner"

# créer les management groups

az deployment tenant create --location $location --template-file ./main.bicep --parameters ./main.bicepparam --name $deploymentName