# Deployment Scripts

This folder contains ready-to-run scripts for deploying Azure and AWS resources for the POC.

## Azure Deployment Script

### PowerShell (Windows)

```powershell
# Navigate to this folder
cd Infrastructure/scripts

# Run the script
.\deploy-azure-resources.ps1
```

**Prerequisites:**
- Azure CLI installed
- Logged in to Azure (`az login`)

**What it does:**
- Creates resource group
- Creates SQL Server and Database
- Creates Container Registry
- Creates App Service Plan
- Creates two App Services (UserService and ProductService)
- Configures connection strings
- Enables CORS
- Saves all variables to `azure-vars.txt`

### Bash (Linux/Mac/Git Bash/WSL)

```bash
# Navigate to this folder
cd Infrastructure/scripts

# Run the script
./deploy-azure-resources.sh
```

**Prerequisites:**
- Azure CLI installed
- Logged in to Azure (`az login`)

## Output

After running the script, you'll get:
- All Azure resources created
- `azure-vars.txt` file with all variables saved
- Summary of created resources with URLs

## Troubleshooting

**Error: Azure CLI not found**
- Install Azure CLI: https://aka.ms/installazurecliwindows
- Or use Azure Cloud Shell

**Error: Not logged in**
- Run `az login` first
- The script will prompt you if not logged in

**Error: Permission denied (Bash)**
- Make script executable: `chmod +x deploy-azure-resources.sh`

**Error: Execution policy (PowerShell)**
- Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- Or run: `powershell -ExecutionPolicy Bypass -File .\deploy-azure-resources.ps1`

## Next Steps

After running the script:
1. Check `azure-vars.txt` for all resource names
2. Run database migrations
3. Deploy your APIs
4. Create Static Web App for Angular

