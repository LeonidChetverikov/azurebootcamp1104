# Variables
RESOURCE_GROUP="azurebootcamp"
VM_NAME="MyWindowsVM"
LOCATION="WestEurope"
IMAGE="Win2019Datacenter"
USERNAME="azureuser"
PASSWORD="P@ssw0rd123!"  # Use a strong password


# Step 1: Check if Resource Group Exists
EXISTING_RG=$(az group show --name $RESOURCE_GROUP --query "name" --output tsv 2>/dev/null)

if [ "$EXISTING_RG" == "$RESOURCE_GROUP" ]; then
  echo "Resource Group '$RESOURCE_GROUP' already exists in Azure."
else
  echo "Resource Group '$RESOURCE_GROUP' does not exist. Creating it now..."
  az group create --name $RESOURCE_GROUP --location $LOCATION
fi


# Step 2: Create a Virtual Machine
az vm create \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME \
  --image $IMAGE \
  --admin-username $USERNAME \
  --admin-password $PASSWORD \
  --authentication-type password

# Step 3: Open Port 3389 for RDP Access
az vm open-port \
  --port 3389 \
  --resource-group $RESOURCE_GROUP \
  --name $VM_NAME
