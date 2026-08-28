# Application Insights Quick Start Guide

## ✅ What's Been Implemented

I've already integrated Application Insights into your Fee Management Service! Here's what's ready:

### **1. NuGet Packages Added**
- ✅ `Microsoft.ApplicationInsights.AspNetCore` - Core Application Insights SDK
- ✅ `Serilog.Sinks.ApplicationInsights` - Send Serilog logs to Application Insights

### **2. Services Created**
- ✅ `ITelemetryService` - Interface for custom telemetry tracking
- ✅ `TelemetryService` - Implementation that sends telemetry to Application Insights
- ✅ `NoOpTelemetryService` - Fallback when Application Insights is not configured

### **3. Telemetry Tracking Added**
- ✅ **Fee Creation** - Tracks when fees are created with SchoolId, FeeType, Amount
- ✅ **S3 Uploads** - Tracks S3 upload operations with success/failure, duration, file size
- ✅ **JWT Generation** - Tracks JWT token generation
- ✅ **Exceptions** - All exceptions are tracked with full context
- ✅ **Dependencies** - S3 operations tracked as dependencies
- ✅ **Custom Metrics** - Response times, durations tracked

### **4. Integration Points**
- ✅ `FeeService` - Tracks fee creation and exceptions
- ✅ `S3Service` - Tracks S3 operations and dependencies
- ✅ `JwtTokenService` - Tracks token generation
- ✅ `GlobalExceptionHandlerMiddleware` - Tracks all exceptions with context

---

## 🚀 Next Steps: Get Your Connection String

### **Step 1: Create Application Insights Resource**

**Option A: Using Azure Portal**

1. Go to [Azure Portal](https://portal.azure.com)
2. Click **"Create a resource"**
3. Search for **"Application Insights"**
4. Click **"Create"**
5. Fill in:
   - **Name**: `fee-management-service-insights` (must be unique)
   - **Resource Group**: Create new or use existing
   - **Region**: Choose closest to you (e.g., `East US`)
   - **Application Type**: `ASP.NET Core`
6. Click **"Review + create"** → **"Create"**
7. Wait 1-2 minutes for deployment

**Option B: Using Azure CLI (Recommended for Automation)**

```bash
# Login to Azure
az login

# Create resource group (if needed)
az group create --name rg-fee-management --location eastus

# Create Application Insights
az monitor app-insights component create \
  --app fee-management-service-insights \
  --location eastus \
  --resource-group rg-fee-management \
  --application-type web

# Get connection string
az monitor app-insights component show \
  --app fee-management-service-insights \
  --resource-group rg-fee-management \
  --query connectionString \
  --output tsv
```

📖 **See `AZURE_CLI_SETUP.md` for detailed Azure CLI instructions**

### **Step 2: Get Connection String**

1. Go to your Application Insights resource
2. In the left menu, find **"Overview"**
3. Look for **"Connection String"** in the Essentials section
4. **Copy the Connection String**

### **Step 3: Add Connection String to Your App**

**Option A: Update appsettings.json (for development)**

```json
{
  "ApplicationInsights": {
    "ConnectionString": "YOUR_CONNECTION_STRING_HERE"
  }
}
```

**Option B: Use Environment Variable (recommended for production)**

```bash
# Windows PowerShell
$env:APPLICATIONINSIGHTS_CONNECTION_STRING="YOUR_CONNECTION_STRING_HERE"

# Linux/Mac
export APPLICATIONINSIGHTS_CONNECTION_STRING="YOUR_CONNECTION_STRING_HERE"
```

**Option C: User Secrets (for development)**

```bash
dotnet user-secrets set "ApplicationInsights:ConnectionString" "YOUR_CONNECTION_STRING_HERE"
```

---

## 🧪 Test It Out

### **1. Run Your Application**

```bash
cd FeeManagementService
dotnet run
```

### **2. Generate Some Telemetry**

Make some API calls:

```bash
# Login
POST http://localhost:5000/api/auth/login
{
  "username": "admin",
  "password": "password"
}

# Generate presigned URL
POST http://localhost:5000/api/fees/presigned-url
Authorization: Bearer YOUR_TOKEN
{
  "feeId": "00000000-0000-0000-0000-000000000001",
  "fileName": "test.jpg",
  "contentType": "image/jpeg",
  "fileSize": 102400
}

# Create fee
POST http://localhost:5000/api/fees
Authorization: Bearer YOUR_TOKEN
{
  "title": "Test Fee",
  "description": "Test Description",
  "amount": 100.00,
  "feeType": "ActivityFee",
  "imageUrl": "https://..."
}
```

### **3. View Telemetry in Azure Portal**

1. Go to your Application Insights resource
2. Wait 1-2 minutes for telemetry to appear
3. Click **"Live Metrics Stream"** to see real-time data
4. Click **"Logs"** to query telemetry

---

## 📊 What You'll See in Application Insights

### **Automatic Telemetry**
- ✅ HTTP Requests (all API calls)
- ✅ Dependencies (SQL Server queries)
- ✅ Exceptions (all errors)
- ✅ Performance counters (CPU, memory)

### **Custom Telemetry (Already Implemented)**
- ✅ `FeeCreated` events - Track fee creation
- ✅ `S3Upload` events - Track S3 operations
- ✅ `JwtTokenGenerated` events - Track authentication
- ✅ Custom metrics - Response times, durations
- ✅ S3 dependencies - Track S3 calls as dependencies

---

## 🔍 Try These Queries in Log Analytics

Open **"Logs"** in Application Insights and try:

```kusto
// View all requests
requests
| where timestamp > ago(1h)
| project timestamp, name, url, resultCode, duration
| order by timestamp desc

// View custom events (fees created)
customEvents
| where name == "FeeCreated"
| project timestamp, customDimensions.SchoolId, customDimensions.FeeType, customMeasurements.FeeAmount
| order by timestamp desc

// View exceptions
exceptions
| where timestamp > ago(1h)
| project timestamp, type, message, outerMessage
| order by timestamp desc

// View S3 uploads
customEvents
| where name == "S3Upload"
| project timestamp, 
    SchoolId = customDimensions.SchoolId,
    FileName = customDimensions.FileName,
    Success = customDimensions.Success,
    Duration = customMeasurements.UploadDurationMs
| order by timestamp desc

// Performance by endpoint
requests
| where timestamp > ago(1h)
| summarize 
    AvgDuration = avg(duration),
    P95Duration = percentile(duration, 95),
    RequestCount = count()
    by name
| order by AvgDuration desc
```

---

## 📚 Learn More

See the full guide: **`Application-Insights_GUIDE.md`**

It includes:
- Detailed setup instructions
- All features explained
- Dashboard creation
- Alert configuration
- Learning exercises

---

## ⚠️ Important Notes

1. **Connection String Required**: Application Insights won't work without a connection string. The app will still run, but telemetry won't be sent.

2. **No-Op Fallback**: If Application Insights is not configured, the app uses `NoOpTelemetryService` so it won't crash.

3. **Cost**: Application Insights has a free tier (5GB/month). Check pricing at [Azure Pricing](https://azure.microsoft.com/pricing/details/monitor/).

4. **Privacy**: Make sure not to log sensitive data (passwords, tokens, etc.) in telemetry properties.

---

## 🎉 You're All Set!

Once you add your connection string, Application Insights will automatically start collecting telemetry. Check the Azure Portal in a few minutes to see your data!

**Happy Monitoring! 🚀**

