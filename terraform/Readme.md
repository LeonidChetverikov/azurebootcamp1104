### Explanation of Usage

#### Random Name Generation
- The `random_pet` resource generates a unique name for the storage account. 
- The `length` parameter determines the number of segments in the generated name (e.g., `happy-salmon-zebra`).
- The `random_pet.storage_account_name.id` dynamically assigns the name to the storage account.

#### Default Location
- The `location` property of the resource group and storage account is set to `"West Europe"`, ensuring consistency.

### Deployment Steps
Follow the same Terraform workflow:
1. **Initialize Terraform:** `terraform init`
2. **Preview Changes:** `terraform plan`
3. **Apply Configuration:** `terraform apply`
