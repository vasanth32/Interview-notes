# Automation & Scripting - Interview Guide

## 1. PowerShell Scripting

### What is PowerShell?

**PowerShell** is a task automation and configuration management framework from Microsoft. It's a command-line shell and scripting language built on .NET.

**Versions:**
- **Windows PowerShell**: 5.1 (built into Windows)
- **PowerShell Core**: 6.0+ (cross-platform, open-source)

**Key Features:**
- Object-oriented (not just text)
- Cmdlets (pronounced "command-lets")
- Piping objects (not just text)
- Access to .NET Framework

---

### Cmdlets and Modules

**Cmdlets:**
- PowerShell commands
- Format: `Verb-Noun`
- Examples: `Get-Process`, `Set-Location`, `New-Item`

**Common Cmdlets:**
```powershell
# Get information
Get-Process          # List running processes
Get-Service          # List services
Get-ChildItem        # List files (ls, dir)
Get-Content          # Read file content (cat, type)

# Set/Change
Set-Location         # Change directory (cd)
Set-Item             # Set value
New-Item             # Create new item
Remove-Item          # Delete item (rm, del)

# Working with objects
Select-Object        # Select properties
Where-Object         # Filter objects
Sort-Object          # Sort objects
```

**Modules:**
- Collections of cmdlets
- Install additional modules

```powershell
# List installed modules
Get-Module -ListAvailable

# Install module
Install-Module -Name Az

# Import module
Import-Module Az
```

---

### Variables and Data Types

**Variables:**
```powershell
# Create variable
$name = "John"
$age = 25
$items = @("apple", "banana", "orange")

# Access variable
Write-Host $name
Write-Host "Age: $age"

# Variable types (PowerShell infers type)
[string]$text = "Hello"
[int]$number = 42
[bool]$flag = $true
[array]$list = @(1, 2, 3)
```

**Arrays:**
```powershell
# Create array
$fruits = @("apple", "banana", "orange")
$numbers = @(1, 2, 3, 4, 5)

# Access elements
$fruits[0]           # First element
$fruits[-1]          # Last element

# Add to array
$fruits += "grape"
```

**Hashtables (Dictionaries):**
```powershell
# Create hashtable
$person = @{
    Name = "John"
    Age = 25
    City = "New York"
}

# Access
$person.Name
$person["Age"]

# Add/Modify
$person["Email"] = "john@example.com"
```

---

### Functions and Modules

**Functions:**
```powershell
function Get-Greeting {
    param(
        [string]$Name
    )
    return "Hello, $Name!"
}

# Call function
Get-Greeting -Name "John"
```

**Advanced Functions:**
```powershell
function Get-UserInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        
        [Parameter(Mandatory=$false)]
        [int]$Age
    )
    
    Write-Verbose "Getting info for $UserName"
    
    $info = @{
        Name = $UserName
        Age = $Age
    }
    
    return $info
}

# Usage
Get-UserInfo -UserName "John" -Age 25 -Verbose
```

**Scripts (.ps1 files):**
```powershell
# Save as script.ps1
param(
    [string]$InputFile,
    [string]$OutputFile
)

Write-Host "Processing $InputFile"
# Script logic here
```

**Execution Policy:**
```powershell
# Check current policy
Get-ExecutionPolicy

# Set policy (requires admin)
Set-ExecutionPolicy RemoteSigned

# Policies:
# - Restricted: No scripts
# - RemoteSigned: Local scripts OK, downloaded must be signed
# - Unrestricted: All scripts OK (not recommended)
```

---

### Error Handling

**Try-Catch-Finally:**
```powershell
try {
    $result = 10 / 0
    Write-Host "Result: $result"
}
catch {
    Write-Host "Error occurred: $($_.Exception.Message)"
    Write-Host "Error type: $($_.Exception.GetType().FullName)"
}
finally {
    Write-Host "This always executes"
}
```

**Error Action:**
```powershell
# Stop on error
Get-Item "nonexistent.txt" -ErrorAction Stop

# Continue on error (default)
Get-Item "nonexistent.txt" -ErrorAction Continue

# Silently continue
Get-Item "nonexistent.txt" -ErrorAction SilentlyContinue
```

**$Error Variable:**
```powershell
# View last error
$Error[0]

# Clear error history
$Error.Clear()
```

---

### Working with IIS (WebAdministration Module)

**Import Module:**
```powershell
Import-Module WebAdministration
```

**Common IIS Cmdlets:**
```powershell
# Get websites
Get-Website

# Get application pools
Get-WebAppPoolState

# Get website details
Get-Website -Name "Default Web Site"

# Start/Stop website
Start-Website -Name "MySite"
Stop-Website -Name "MySite"
Restart-WebAppPool -Name "MyAppPool"

# Create website
New-Website -Name "MySite" `
    -PhysicalPath "C:\inetpub\wwwroot\MySite" `
    -Port 80

# Create application pool
New-WebAppPool -Name "MyAppPool"
Set-ItemProperty "IIS:\AppPools\MyAppPool" `
    -Name managedRuntimeVersion -Value "v4.0"

# Set binding
New-WebBinding -Name "MySite" `
    -Protocol http `
    -Port 8080 `
    -IPAddress "*"
```

**Example Script - Backup Website:**
```powershell
param(
    [string]$WebsiteName = "Default Web Site",
    [string]$BackupPath = "C:\Backups"
)

Import-Module WebAdministration

$website = Get-Website -Name $WebsiteName
$physicalPath = $website.physicalPath

$backupFolder = Join-Path $BackupPath (Get-Date -Format "yyyyMMdd_HHmmss")
New-Item -ItemType Directory -Path $backupFolder -Force

Copy-Item -Path $physicalPath -Destination $backupFolder -Recurse

Write-Host "Backup completed: $backupFolder"
```

---

### Azure PowerShell Modules

**Install Azure PowerShell:**
```powershell
Install-Module -Name Az -AllowClobber
```

**Login:**
```powershell
Connect-AzAccount
```

**Common Azure Cmdlets:**
```powershell
# Resource Groups
Get-AzResourceGroup
New-AzResourceGroup -Name "MyRG" -Location "East US"

# Web Apps
Get-AzWebApp
New-AzWebApp -ResourceGroupName "MyRG" `
    -Name "myapp" `
    -Location "East US" `
    -AppServicePlan "MyPlan"

# SQL Database
Get-AzSqlDatabase
New-AzSqlDatabase -ResourceGroupName "MyRG" `
    -ServerName "myserver" `
    -DatabaseName "mydb"
```

**Example - Deploy to Azure:**
```powershell
# Login
Connect-AzAccount

# Set context
Set-AzContext -SubscriptionId "your-subscription-id"

# Deploy web app
$publishProfile = Get-AzWebAppPublishingProfile `
    -ResourceGroupName "MyRG" `
    -Name "myapp"

# Publish using publish profile
```

---

### Automation Tasks

**Scheduled Tasks:**
```powershell
# Create scheduled task
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-File C:\Scripts\Backup.ps1"

$trigger = New-ScheduledTaskTrigger -Daily -At 2am

Register-ScheduledTask -TaskName "DailyBackup" `
    -Action $action `
    -Trigger $trigger
```

**File Operations:**
```powershell
# Read file
$content = Get-Content "C:\file.txt"

# Write file
"Hello World" | Out-File "C:\output.txt"

# Append
"New line" | Add-Content "C:\file.txt"

# Process CSV
$data = Import-Csv "C:\data.csv"
$data | Where-Object { $_.Age -gt 18 } | Export-Csv "C:\filtered.csv"
```

---

## 2. Python Basics (Advantage)

### Basic Syntax

**Variables:**
```python
name = "John"
age = 25
is_active = True
```

**Data Types:**
```python
# String
text = "Hello"
text = 'World'

# Numbers
integer = 42
float_num = 3.14

# Boolean
flag = True
flag = False

# List (array)
fruits = ["apple", "banana", "orange"]

# Dictionary (hashtable)
person = {
    "name": "John",
    "age": 25,
    "city": "New York"
}
```

**Control Flow:**
```python
# If-else
if age >= 18:
    print("Adult")
elif age >= 13:
    print("Teen")
else:
    print("Child")

# Loops
for fruit in fruits:
    print(fruit)

for i in range(5):
    print(i)

# While loop
count = 0
while count < 5:
    print(count)
    count += 1
```

### Data Structures

**Lists:**
```python
# Create
items = [1, 2, 3]
items = list()

# Access
items[0]          # First element
items[-1]         # Last element

# Modify
items.append(4)   # Add to end
items.insert(0, 0) # Insert at index
items.remove(2)   # Remove value
items.pop()       # Remove and return last

# Slicing
items[1:3]        # Elements 1 to 2
items[:2]         # First 2 elements
items[2:]         # From index 2 to end
```

**Dictionaries:**
```python
# Create
person = {"name": "John", "age": 25}
person = dict()

# Access
person["name"]
person.get("name", "Default")  # With default

# Modify
person["email"] = "john@example.com"
person.update({"city": "NYC"})
del person["age"]
```

### File Operations

**Read File:**
```python
# Read entire file
with open("file.txt", "r") as f:
    content = f.read()

# Read line by line
with open("file.txt", "r") as f:
    for line in f:
        print(line.strip())
```

**Write File:**
```python
# Write
with open("output.txt", "w") as f:
    f.write("Hello World\n")

# Append
with open("output.txt", "a") as f:
    f.write("New line\n")
```

**CSV:**
```python
import csv

# Read CSV
with open("data.csv", "r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        print(row["name"], row["age"])

# Write CSV
with open("output.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(["Name", "Age"])
    writer.writerow(["John", 25])
```

### HTTP Requests (requests library)

**Install:**
```bash
pip install requests
```

**Basic Usage:**
```python
import requests

# GET request
response = requests.get("https://api.example.com/users")
data = response.json()
print(data)

# POST request
response = requests.post(
    "https://api.example.com/users",
    json={"name": "John", "age": 25}
)

# With headers
headers = {"Authorization": "Bearer token"}
response = requests.get(
    "https://api.example.com/data",
    headers=headers
)

# Error handling
try:
    response = requests.get("https://api.example.com/data")
    response.raise_for_status()  # Raise exception for bad status
    data = response.json()
except requests.exceptions.RequestException as e:
    print(f"Error: {e}")
```

### Scripting for Automation

**Example - API Health Check:**
```python
import requests
import time
import sys

def check_health(url):
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            print(f"✓ {url} is healthy")
            return True
        else:
            print(f"✗ {url} returned {response.status_code}")
            return False
    except Exception as e:
        print(f"✗ {url} failed: {e}")
        return False

# Check multiple endpoints
urls = [
    "https://api.example.com/health",
    "https://api.example.com/status"
]

all_healthy = True
for url in urls:
    if not check_health(url):
        all_healthy = False

sys.exit(0 if all_healthy else 1)
```

### Integration with .NET Applications

**Calling Python from C#:**
```csharp
// Using Process
var process = new Process
{
    StartInfo = new ProcessStartInfo
    {
        FileName = "python",
        Arguments = "script.py",
        RedirectStandardOutput = true,
        UseShellExecute = false
    }
};

process.Start();
string output = process.StandardOutput.ReadToEnd();
process.WaitForExit();
```

**Python.NET (Alternative):**
```python
# Install: pip install pythonnet
import clr
clr.AddReference("System")
from System import Console
Console.WriteLine("Hello from Python!")
```

---

## Interview Questions to Prepare

1. **What is PowerShell? How is it different from Command Prompt?**
2. **How do you work with IIS using PowerShell?**
3. **Explain PowerShell error handling.**
4. **How do you create and use PowerShell functions?**
5. **What are PowerShell modules? How do you use them?**
6. **How do you make HTTP requests in Python?**
7. **Explain Python file operations.**
8. **How would you automate a deployment task using PowerShell?**
9. **What is the difference between PowerShell and Python?**
10. **How do you schedule PowerShell scripts to run automatically?**

