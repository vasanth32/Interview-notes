# Online School Platform - User Stories

## Overview

This document contains detailed user stories for the Edlio-like Online School Platform microservices architecture. Each user story includes:
- User story description
- Acceptance criteria
- High-level flow
- Technical implementation details
- Cursor AI prompts for POC development

---

## User Story 1: School Admin Creates Fee (Activity/Class/Course Fee)

### Story Description

**As a** School Administrator  
**I want to** create new fees (activity fees, class fees, course fees, or similar fee types)  
**So that** I can define and manage fee structures for my school with associated images

### Context

- **Scale**: 10,000+ schools can access the School Management Portal simultaneously
- **User Type**: School Administrators only
- **Service**: Fee Management Service (Microservice)
- **Multi-Tenancy**: Each school (tenant) can only create/manage their own fees

### Acceptance Criteria

1. ✅ School admin can create a new fee with:
   - Title (required, max 200 characters)
   - Description (optional, max 2000 characters)
   - Fee Amount (required, decimal, min 0.01)
   - Image (optional, max 5MB, formats: JPG, PNG, WebP)
   - Fee Type (Activity Fee, Class Fee, Course Fee, Transport Fee, Lab Fee, Misc Fee)

2. ✅ Image upload must be stored in AWS S3
3. ✅ Only authenticated School Admins can create fees
4. ✅ School admin can only create fees for their own school (tenant isolation)
5. ✅ System handles high traffic (10k+ concurrent schools)
6. ✅ All fee creation operations are logged for audit
7. ✅ API returns appropriate success/error responses

### Business Rules

- Fee amount must be positive (> 0)
- Image file size limit: 5MB
- Supported image formats: JPG, JPEG, PNG, WebP
- Each fee must be associated with a school (tenant)
- Fee creation timestamp is automatically recorded
- Fee status defaults to "Active"

---

## High-Level Flow

### Request Flow

```
┌─────────────────┐
│  School Admin   │
│     Portal      │
└────────┬────────┘
         │
         │ 1. POST /api/fees
         │    Headers: Authorization: Bearer {JWT}
         │    Body: FormData (title, description, amount, feeType, image)
         ▼
┌─────────────────┐
│   API Gateway   │
└────────┬────────┘
         │
         │ 2. Validate JWT Token
         │    Extract: UserId, SchoolId (TenantId), Role
         │    Verify: Role = "SchoolAdmin"
         ▼
┌─────────────────┐
│ Fee Management  │
│    Service      │
└────────┬────────┘
         │
         │ 3. Validate Request
         │    - Title, Amount required
         │    - Amount > 0
         │    - Image validation (size, format)
         │
         │ 4. Upload Image to S3 (if provided)
         │    - Generate unique filename
         │    - Upload to: s3://bucket/schools/{schoolId}/fees/{feeId}/image.jpg
         │    - Get S3 URL
         │
         │ 5. Save Fee to Database
         │    - Insert into Fees table
         │    - Store S3 image URL
         │
         │ 6. Publish Event (Async)
         │    - FeeCreated event to message bus
         │
         │ 7. Return Response
         │    - Fee ID, Created Date, S3 Image URL
         ▼
┌─────────────────┐
│   Response to   │
│  School Admin   │
└─────────────────┘
```

### Detailed Step-by-Step Flow

1. **Authentication & Authorization**
   - School admin sends request with JWT token in Authorization header
   - API Gateway validates token with Identity Service
   - Extract claims: `UserId`, `SchoolId` (TenantId), `Role`
   - Verify role is "SchoolAdmin"
   - Pass SchoolId to Fee Management Service

2. **Request Validation**
   - Validate required fields: Title, Fee Amount
   - Validate fee amount is positive decimal
   - Validate image (if provided):
     - File size ≤ 5MB
     - File type is JPG, PNG, or WebP
     - File is valid image format

3. **Image Upload to S3** (if image provided)
   - Generate unique filename: `{feeId}_{timestamp}_{random}.{extension}`
   - S3 Key: `schools/{schoolId}/fees/{feeId}/{filename}`
   - Upload to S3 bucket with public-read or presigned URL access
   - Get S3 URL: `https://{bucket}.s3.{region}.amazonaws.com/schools/{schoolId}/fees/{feeId}/{filename}`
   - Handle upload failures gracefully

4. **Database Operation**
   - Create Fee entity with:
     - Id (Guid)
     - SchoolId (from JWT claim)
     - Title
     - Description
     - Amount (decimal)
     - FeeType (enum)
     - ImageUrl (S3 URL, nullable)
     - Status (Active)
     - CreatedBy (UserId from JWT)
     - CreatedAt (UTC timestamp)
   - Save to Fees table
   - Handle database errors

5. **Event Publishing** (Async, non-blocking)
   - Publish `FeeCreated` event to message bus
   - Event contains: FeeId, SchoolId, Amount, FeeType, CreatedAt
   - Other services (Notification, Reporting) can subscribe

6. **Response**
   - Return 201 Created with fee details
   - Include FeeId, CreatedAt, ImageUrl

### Error Handling

- **401 Unauthorized**: Invalid or missing JWT token
- **403 Forbidden**: User is not a SchoolAdmin
- **400 Bad Request**: Validation errors (missing title, invalid amount, invalid image)
- **413 Payload Too Large**: Image exceeds 5MB
- **500 Internal Server Error**: Database or S3 upload failures
- **503 Service Unavailable**: S3 service unavailable (with retry logic)

---

## Technical Implementation Details

### Technology Stack

- **Framework**: ASP.NET Core 8.0 (Web API)
- **Database**: SQL Server / PostgreSQL
- **ORM**: Entity Framework Core
- **Storage**: AWS S3 (for images)
- **Authentication**: JWT Bearer Tokens
- **Message Bus**: RabbitMQ / AWS SQS (for events)
- **Caching**: Redis (for high traffic scenarios)

### Database Schema

#### Fees Table

```sql
CREATE TABLE Fees (
    Id UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    SchoolId UNIQUEIDENTIFIER NOT NULL, -- Tenant identifier
    Title NVARCHAR(200) NOT NULL,
    Description NVARCHAR(2000) NULL,
    Amount DECIMAL(18, 2) NOT NULL CHECK (Amount > 0),
    FeeType NVARCHAR(50) NOT NULL, -- ActivityFee, ClassFee, CourseFee, TransportFee, LabFee, MiscFee
    ImageUrl NVARCHAR(500) NULL, -- S3 URL
    Status NVARCHAR(20) NOT NULL DEFAULT 'Active', -- Active, Inactive, Archived
    CreatedBy NVARCHAR(450) NOT NULL, -- UserId
    CreatedAt DATETIME2 NOT NULL DEFAULT GETUTCDATE(),
    UpdatedBy NVARCHAR(450) NULL,
    UpdatedAt DATETIME2 NULL,
    
    INDEX IX_Fees_SchoolId (SchoolId),
    INDEX IX_Fees_FeeType (FeeType),
    INDEX IX_Fees_Status (Status),
    INDEX IX_Fees_CreatedAt (CreatedAt)
);
```

### API Endpoint

**Endpoint**: `POST /api/fees`

**Request Headers**:
```
Authorization: Bearer {JWT_TOKEN}
Content-Type: multipart/form-data
```

**Request Body** (FormData):
```
title: string (required)
description: string (optional)
amount: decimal (required)
feeType: string (required) - ActivityFee | ClassFee | CourseFee | TransportFee | LabFee | MiscFee
image: IFormFile (optional)
```

**Response** (201 Created):
```json
{
  "id": "guid",
  "schoolId": "guid",
  "title": "string",
  "description": "string",
  "amount": 100.00,
  "feeType": "ActivityFee",
  "imageUrl": "https://bucket.s3.region.amazonaws.com/path/to/image.jpg",
  "status": "Active",
  "createdAt": "2024-01-15T10:30:00Z",
  "createdBy": "userId"
}
```

### Project Structure

```
FeeManagementService/
├── Controllers/
│   └── FeesController.cs
├── Models/
│   ├── CreateFeeRequest.cs
│   ├── FeeResponse.cs
│   └── Fee.cs (Entity)
├── Services/
│   ├── IFeeService.cs
│   ├── FeeService.cs
│   ├── IS3Service.cs
│   └── S3Service.cs
├── Data/
│   ├── FeeDbContext.cs
│   └── Migrations/
├── Middleware/
│   └── TenantMiddleware.cs (extracts SchoolId from JWT)
├── Validators/
│   └── CreateFeeRequestValidator.cs
└── Program.cs
```

### Key Components

#### 1. FeesController.cs
- Handles HTTP requests
- Validates authentication/authorization
- Calls FeeService
- Returns appropriate HTTP responses

#### 2. FeeService.cs
- Business logic for fee creation
- Coordinates S3 upload
- Database operations
- Event publishing

#### 3. S3Service.cs
- AWS S3 integration
- Image upload logic
- URL generation
- Error handling

#### 4. TenantMiddleware.cs
- Extracts SchoolId from JWT claims
- Sets HttpContext.Items["SchoolId"] for downstream use
- Ensures tenant isolation

### Security Considerations

1. **Authentication**
   - JWT token validation via Identity Service
   - Token must contain valid SchoolId claim

2. **Authorization**
   - Role-based: Only "SchoolAdmin" role can create fees
   - Tenant isolation: SchoolId from token is used (cannot be overridden)

3. **Input Validation**
   - Sanitize title and description (prevent XSS)
   - Validate image file type (prevent malicious uploads)
   - Validate image size (prevent DoS)

4. **S3 Security**
   - Use IAM roles with least privilege (or IAM user with minimal permissions for POC)
   - S3 bucket policy: Only allow uploads from service
   - For POC: Public read access for images (direct S3 URLs)
   - For Production: Private bucket + presigned URLs for GET operations (not needed for uploads since we use server-side upload)
   - Enable S3 versioning and encryption (SSE-S3 or SSE-KMS)

5. **Audit Logging**
   - Log all fee creation attempts
   - Include: UserId, SchoolId, Timestamp, IP Address
   - Store in audit log table or logging service

### High Traffic Handling Strategies

1. **Async Image Upload**
   - Upload image to S3 asynchronously (don't block request)
   - Save fee record first, update image URL later
   - Use background job for image processing (resize, optimize)

2. **Database Optimization**
   - Indexes on SchoolId, FeeType, Status, CreatedAt
   - Connection pooling
   - Read replicas for read operations

3. **Caching**
   - Cache fee lists per school (Redis)
   - Cache S3 image URLs (if using presigned URLs for private access)
   - Invalidate cache on fee creation

4. **Rate Limiting**
   - API Gateway: Limit requests per school
   - Per-user rate limiting: Max 100 fee creations per hour

5. **Load Balancing**
   - Multiple instances of Fee Management Service
   - S3 uploads can be parallelized

6. **Message Queue**
   - Publish events asynchronously (don't block response)
   - Use message queue for event processing

### AWS S3 Configuration

**📋 Quick Summary**:
- **Presigned URLs**: ❌ NOT needed for uploads (we use server-side upload via AWS SDK)
- **Presigned URLs**: ✅ Optional for GET operations if images are private (skip for POC)
- **S3 Setup**: Use AWS Console (fastest) or AWS CLI for 2-hour POC
- **Access**: Use IAM user with access keys for POC (IAM roles for production)

**Bucket Structure**:
```
s3://school-platform-fees/
  └── schools/
      └── {schoolId}/
          └── fees/
              └── {feeId}/
                  └── {filename}.jpg
```

**Presigned URLs - When to Use**:
- ❌ **NOT needed for server-side uploads**: Since our API receives the image and uploads it directly to S3 using AWS SDK, we don't need presigned URLs for uploads.
- ✅ **Optional for GET operations**: If you want to make images private and generate temporary access URLs for viewing, presigned URLs are useful. For a 2-hour POC, you can make the bucket public-read or use public URLs directly.
- **For POC**: Skip presigned URLs, use direct S3 URLs. Add presigned URLs later if you need private image access.

**S3 Bucket Policy** (Example):
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT:role/FeeServiceRole"
      },
      "Action": ["s3:PutObject", "s3:GetObject"],
      "Resource": "arn:aws:s3:::school-platform-fees/schools/*/fees/*/*"
    }
  ]
}
```

**IAM Role Permissions**:
- `s3:PutObject` on `school-platform-fees/schools/*/fees/*/*`
- `s3:GetObject` on `school-platform-fees/schools/*/fees/*/*`

---

## AWS S3 Setup - Quick Start Guide

### Option 1: AWS Console (Fastest - ~2 minutes) ⚡

**Steps**:
1. Log in to AWS Console → S3
2. Click "Create bucket"
3. **Bucket name**: `school-platform-fees` (must be globally unique, add your suffix)
4. **Region**: Choose your region (e.g., `us-east-1`)
5. **Block Public Access**: 
   - For POC: Uncheck "Block all public access" (to allow direct image URLs)
   - For Production: Keep blocked, use presigned URLs
6. **Bucket Versioning**: Enable (optional, for POC can skip)
7. **Encryption**: Enable (SSE-S3 is fine for POC)
8. Click "Create bucket"

**IAM User Setup** (for API credentials):
1. Go to IAM → Users → Create user
2. User name: `fee-service-s3-user`
3. **Access type**: Programmatic access
4. **Permissions**: Attach policy directly → Create policy
5. **Policy JSON**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::school-platform-fees/*"
    }
  ]
}
```
6. Name policy: `FeeServiceS3Policy`
7. Attach policy to user
8. **Save Access Key ID and Secret Access Key** (you'll need these for appsettings.json)

**Done!** Use Access Key ID and Secret Access Key in your appsettings.json.

---

### Option 2: AWS CLI (Fast - ~3 minutes) ⚡⚡

**Prerequisites**:
- AWS CLI installed: `aws --version`
- AWS CLI configured: `aws configure` (if not done)

**Commands**:

```bash
# 1. Create S3 bucket
aws s3 mb s3://school-platform-fees --region us-east-1

# 2. Enable versioning (optional)
aws s3api put-bucket-versioning \
  --bucket school-platform-fees \
  --versioning-configuration Status=Enabled

# 3. Enable encryption (optional)
aws s3api put-bucket-encryption \
  --bucket school-platform-fees \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }]
  }'

# 4. Set bucket policy for public read (for POC - optional)
aws s3api put-bucket-policy --bucket school-platform-fees --policy '{
  "Version": "2012-10-17",
  "Statement": [{
    "Sid": "PublicReadGetObject",
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::school-platform-fees/*"
  }]
}'

# 5. Create IAM user
aws iam create-user --user-name fee-service-s3-user

# 6. Create IAM policy
aws iam create-policy \
  --policy-name FeeServiceS3Policy \
  --policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::school-platform-fees/*"
    }]
  }'

# 7. Attach policy to user (replace ACCOUNT_ID and POLICY_ARN)
aws iam attach-user-policy \
  --user-name fee-service-s3-user \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/FeeServiceS3Policy

# 8. Create access key for user
aws iam create-access-key --user-name fee-service-s3-user

# Save the AccessKeyId and SecretAccessKey from output!
```

**Verify**:
```bash
aws s3 ls s3://school-platform-fees
```

---

### Option 3: Terraform (Best for Infrastructure as Code) ⚡⚡⚡

**Create `s3-setup.tf`**:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # Change to your region
}

# S3 Bucket
resource "aws_s3_bucket" "fee_images" {
  bucket = "school-platform-fees" # Add your suffix for uniqueness

  tags = {
    Name        = "Fee Management Images"
    Environment = "POC"
  }
}

# Enable versioning
resource "aws_s3_bucket_versioning" "fee_images_versioning" {
  bucket = aws_s3_bucket.fee_images.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "fee_images_encryption" {
  bucket = aws_s3_bucket.fee_images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Public read access policy (for POC - remove for production)
resource "aws_s3_bucket_public_access_block" "fee_images_public" {
  bucket = aws_s3_bucket.fee_images.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "fee_images_public_read" {
  bucket = aws_s3_bucket.fee_images.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.fee_images.arn}/*"
      }
    ]
  })
}

# IAM User for Service
resource "aws_iam_user" "fee_service_s3" {
  name = "fee-service-s3-user"
  tags = {
    Purpose = "Fee Management Service S3 Access"
  }
}

# IAM Policy
resource "aws_iam_policy" "fee_service_s3_policy" {
  name        = "FeeServiceS3Policy"
  description = "Policy for Fee Management Service to access S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.fee_images.arn}/*"
      }
    ]
  })
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "fee_service_s3_attachment" {
  user       = aws_iam_user.fee_service_s3.name
  policy_arn = aws_iam_policy.fee_service_s3_policy.arn
}

# Create access key
resource "aws_iam_access_key" "fee_service_s3_key" {
  user = aws_iam_user.fee_service_s3.name
}

# Output access key (sensitive)
output "access_key_id" {
  value     = aws_iam_access_key.fee_service_s3_key.id
  sensitive = true
}

output "secret_access_key" {
  value     = aws_iam_access_key.fee_service_s3_key.secret
  sensitive = true
}

output "bucket_name" {
  value = aws_s3_bucket.fee_images.bucket
}

output "bucket_region" {
  value = aws_s3_bucket.fee_images.region
}
```

**Commands**:
```bash
# Initialize Terraform
terraform init

# Review plan
terraform plan

# Apply (creates resources)
terraform apply

# Get outputs (access keys)
terraform output access_key_id
terraform output secret_access_key
terraform output bucket_name
terraform output bucket_region

# Destroy (when done testing)
terraform destroy
```

---

### Quick Setup Comparison

| Method | Time | Best For |
|--------|------|----------|
| **AWS Console** | ~2 min | Quick POC, one-time setup |
| **AWS CLI** | ~3 min | Scriptable, repeatable |
| **Terraform** | ~5 min | Infrastructure as Code, production |

**Recommendation for 2-hour POC**: Use **AWS Console** (fastest) or **AWS CLI** (if you prefer command line).

---

### appsettings.json Configuration

After setting up S3, add to your `appsettings.json`:

```json
{
  "AWS": {
    "S3": {
      "BucketName": "school-platform-fees",
      "Region": "us-east-1",
      "AccessKey": "YOUR_ACCESS_KEY_ID",
      "SecretKey": "YOUR_SECRET_ACCESS_KEY"
    }
  }
}
```

**⚠️ Security Note**: For production, use IAM roles (EC2/ECS/Lambda) instead of access keys. For POC, access keys in appsettings.json are acceptable.

---

## Cursor AI Prompts for POC Implementation

### Prompt 1: Project Setup and Structure

```
C
```

### Prompt 2: Database Model and Context

```
Create the database model and DbContext for Fee Management:

1. Create Fee entity model in Models/Fee.cs:
   - Id (Guid, primary key)
   - SchoolId (Guid, required, indexed)
   - Title (string, max 200, required)
   - Description (string, max 2000, nullable)
   - Amount (decimal, required, > 0)
   - FeeType (enum: ActivityFee, ClassFee, CourseFee, TransportFee, LabFee, MiscFee)
   - ImageUrl (string, nullable, max 500)
   - Status (enum: Active, Inactive, Archived, default Active)
   - CreatedBy (string, required)
   - CreatedAt (DateTime, required, UTC)
   - UpdatedBy (string, nullable)
   - UpdatedAt (DateTime?, nullable)

2. Create FeeDbContext in Data/FeeDbContext.cs:
   - DbSet<Fee> Fees
   - Configure Fee entity with Fluent API:
     - Title max length 200
     - Description max length 2000
     - ImageUrl max length 500
     - Indexes on SchoolId, FeeType, Status, CreatedAt
     - Amount check constraint > 0

3. Create initial migration: Add-Migration InitialCreate

4. Update Program.cs to register FeeDbContext with connection string from appsettings.json
```

### Prompt 3: Request/Response Models and Validation

```
Create request/response models and validation:

1. Create CreateFeeRequest.cs in Models/:
   - Title (string, required, max 200)
   - Description (string, optional, max 2000)
   - Amount (decimal, required, > 0)
   - FeeType (string, required, must be valid enum value)
   - Image (IFormFile, optional, max 5MB, only JPG/PNG/WebP)

2. Create FeeResponse.cs in Models/:
   - All Fee properties
   - Use AutoMapper or manual mapping

3. Create CreateFeeRequestValidator.cs in Validators/ using FluentValidation:
   - Title: NotEmpty, MaximumLength(200)
   - Description: MaximumLength(2000) when not null
   - Amount: GreaterThan(0)
   - FeeType: Must be valid enum value
   - Image: 
     - When not null: Max file size 5MB
     - Allowed extensions: .jpg, .jpeg, .png, .webp
     - Must be valid image format

4. Register FluentValidation in Program.cs
```

### Prompt 4: AWS S3 Service

```
Create AWS S3 service for image uploads:

1. Create IS3Service.cs interface in Services/:
   - Task<string> UploadImageAsync(IFormFile imageFile, string schoolId, string feeId)
   - Task<bool> DeleteImageAsync(string imageUrl)
   - (Optional for future: Task<string> GeneratePresignedUrlAsync(string imageUrl, int expirationMinutes = 60) - only if you need private image access)

2. Create S3Service.cs implementation:
   - Use AWSSDK.S3
   - Constructor: IConfiguration, ILogger<S3Service>
   - UploadImageAsync:
     - Validate image before upload:
       - Check file size (max 5MB)
       - Check file extension (.jpg, .jpeg, .png, .webp)
       - Validate it's a valid image file
     - Generate unique filename: {feeId}_{timestamp}_{Guid}.{extension}
     - S3 key: schools/{schoolId}/fees/{feeId}/{filename}
     - Upload to S3 bucket using PutObjectRequest:
       - Set ContentType based on file extension
       - Set ServerSideEncryptionMethod = ServerSideEncryptionMethod.AES256
       - Use async/await for upload
     - Return S3 URL: https://{bucket}.s3.{region}.amazonaws.com/{key}
     - Handle exceptions:
       - AmazonS3Exception → Log and rethrow
       - UnauthorizedAccessException → Log and throw
       - Exception → Log and wrap in custom exception
   - DeleteImageAsync:
     - Extract S3 key from URL
     - Delete object from S3
     - Return true if successful, false otherwise
   - Use async/await for all S3 operations
   - Log all S3 operations (upload, delete)

3. Register S3Service in Program.cs:
   - Read AWS config from appsettings.json:
     - AWS:S3:BucketName
     - AWS:S3:Region
     - AWS:S3:AccessKey (optional if using IAM role)
     - AWS:S3:SecretKey (optional if using IAM role)
   - Create AmazonS3Client:
     - If AccessKey/SecretKey provided: use BasicAWSCredentials
     - Otherwise: use default credential chain (IAM role, environment variables, etc.)
     - Set region from configuration
   - Register S3Service as Scoped

4. Add S3 configuration to appsettings.json:
   - AWS:S3:BucketName = "school-platform-fees"
   - AWS:S3:Region = "us-east-1"
   - AWS:S3:AccessKey = "YOUR_ACCESS_KEY" (for POC, use access keys)
   - AWS:S3:SecretKey = "YOUR_SECRET_KEY" (for POC, use access keys)

5. Note: Presigned URLs are NOT needed for server-side uploads. We upload directly from API to S3 using AWS SDK.
```

### Prompt 5: Tenant Middleware

```
Create middleware to extract tenant (SchoolId) from JWT:

1. Create TenantMiddleware.cs in Middleware/:
   - Extract SchoolId from JWT claim (claim name: "SchoolId" or "TenantId")
   - Set HttpContext.Items["SchoolId"] = schoolId
   - If SchoolId not found, return 401 Unauthorized
   - Also extract UserId and Role from JWT claims
   - Set HttpContext.Items["UserId"] and HttpContext.Items["Role"]

2. Register middleware in Program.cs:
   - app.UseAuthentication() (before middleware)
   - app.UseMiddleware<TenantMiddleware>() (after authentication)

3. Create extension method GetSchoolId() for HttpContext to easily access SchoolId
```

### Prompt 6: Fee Service

```
Create Fee service with business logic:

1. Create IFeeService.cs interface in Services/:
   - Task<FeeResponse> CreateFeeAsync(CreateFeeRequest request, string schoolId, string userId)

2. Create FeeService.cs implementation:
   - Constructor: FeeDbContext, IS3Service, ILogger<FeeService>
   - CreateFeeAsync:
     - Validate request (use FluentValidation)
     - If image provided: Upload to S3 via IS3Service
     - Create Fee entity:
       - Generate new Guid for Id
       - Set SchoolId from parameter (from middleware)
       - Set CreatedBy = userId
       - Set CreatedAt = DateTime.UtcNow
       - Set ImageUrl from S3 upload result
     - Save to database via DbContext
     - Map to FeeResponse
     - Return response
     - Handle exceptions (DbUpdateException, S3Exception, etc.)
     - Log all operations

3. Register FeeService in Program.cs (Scoped)
```

### Prompt 7: Fees Controller

```
Create FeesController with authorization:

1. Create FeesController.cs in Controllers/:
   - [ApiController], [Route("api/[controller]")]
   - Constructor: IFeeService, ILogger<FeesController>
   - [HttpPost] CreateFee endpoint:
     - [Authorize(Roles = "SchoolAdmin")]
     - [RequestSizeLimit(5242880)] // 5MB limit
     - Parameter: [FromForm] CreateFeeRequest request
     - Get SchoolId from HttpContext.Items["SchoolId"]
     - Get UserId from HttpContext.Items["UserId"] or User.Identity.Name
     - Call IFeeService.CreateFeeAsync
     - Return 201 Created with FeeResponse
     - Handle exceptions:
       - ValidationException → 400 Bad Request
       - UnauthorizedAccessException → 401 Unauthorized
       - InvalidOperationException → 403 Forbidden
       - Exception → 500 Internal Server Error
     - Log all requests and errors

2. Add proper error responses with ProblemDetails format
3. Add Swagger/OpenAPI documentation attributes
```

### Prompt 8: JWT Authentication Setup

```
Configure JWT authentication in Program.cs:

1. Add JWT authentication:
   - AddAuthentication().AddJwtBearer()
   - Configure options:
     - ValidateIssuer = true
     - ValidateAudience = true
     - ValidateLifetime = true
     - ValidateIssuerSigningKey = true
     - IssuerSigningKey from appsettings.json
     - ValidIssuer and ValidAudience from appsettings.json

2. Add appsettings.json configuration:
   - JwtSettings:
     - Issuer
     - Audience
     - SecretKey (base64 encoded, at least 256 bits)
     - ExpirationMinutes (default 60)

3. Test with a sample JWT token that includes:
   - Claim: "SchoolId" (Guid)
   - Claim: "UserId" (string)
   - Claim: "Role" = "SchoolAdmin"
   - Standard claims: sub, exp, iat, iss, aud
```

### Prompt 9: Error Handling and Logging

```
Add global error handling and logging:

1. Create GlobalExceptionHandler middleware:
   - Catch all unhandled exceptions
   - Log exceptions with Serilog
   - Return appropriate HTTP status codes
   - Return ProblemDetails format

2. Configure Serilog in Program.cs:
   - Write to Console
   - Write to File (optional)
   - Include correlation IDs for request tracking
   - Log level from appsettings.json

3. Add request logging middleware:
   - Log all incoming requests (method, path, SchoolId, UserId)
   - Log response status codes
   - Exclude sensitive data from logs

4. Register exception handler in Program.cs
```

### Prompt 10: Testing and Documentation

```
Add testing setup and API documentation:

1. Create Postman collection or Swagger test:
   - POST /api/fees endpoint
   - Include sample JWT token in Authorization header
   - Test cases:
     - Valid request with image
     - Valid request without image
     - Missing required fields
     - Invalid amount (negative or zero)
     - Image too large (>5MB)
     - Invalid image format
     - Unauthorized (no token)
     - Forbidden (wrong role)

2. Update Swagger/OpenAPI:
   - Add XML comments to controller and models
   - Configure Swagger to include JWT authentication
   - Add example requests/responses

3. Create README.md with:
   - Setup instructions
   - Environment variables/configuration
   - How to run migrations
   - How to test the API
   - AWS S3 setup instructions
```

### Prompt 11: High Traffic Optimizations (Optional for POC)

```
Add optimizations for high traffic (if time permits):

1. Add Redis caching:
   - Cache fee lists per school (5-minute TTL)
   - Invalidate cache on fee creation
   - Use IDistributedCache

2. Add response compression:
   - app.UseResponseCompression() in Program.cs

3. Add rate limiting:
   - Use AspNetCoreRateLimit or custom middleware
   - Limit: 100 requests per hour per school

4. Optimize database:
   - Add indexes (already in migration)
   - Use async/await for all DB operations
   - Consider read replicas (for production)

5. Add health checks:
   - /health endpoint
   - Check database connectivity
   - Check S3 connectivity
```

---

## Implementation Checklist

### Phase 1: Setup (15 minutes)
- [ ] Create ASP.NET Core Web API project
- [ ] Install NuGet packages
- [ ] Create folder structure
- [ ] Configure appsettings.json

### Phase 2: Database (20 minutes)
- [ ] Create Fee entity model
- [ ] Create FeeDbContext
- [ ] Create and run migration
- [ ] Test database connection

### Phase 3: AWS S3 Integration (25 minutes)
- [ ] Create IS3Service interface
- [ ] Implement S3Service
- [ ] Configure AWS credentials
- [ ] Test S3 upload manually

### Phase 4: Business Logic (20 minutes)
- [ ] Create request/response models
- [ ] Create FluentValidation validators
- [ ] Create IFeeService and FeeService
- [ ] Implement fee creation logic

### Phase 5: API Endpoint (20 minutes)
- [ ] Create TenantMiddleware
- [ ] Configure JWT authentication
- [ ] Create FeesController
- [ ] Add authorization attributes

### Phase 6: Testing (20 minutes)
- [ ] Test with Postman/Swagger
- [ ] Test all validation scenarios
- [ ] Test error handling
- [ ] Verify S3 uploads
- [ ] Verify database saves

### Total Estimated Time: ~2 hours

---

## Notes for POC

1. **Simplifications for 2-hour POC**:
   - Skip event publishing to message bus (can add later)
   - Skip caching (can add later)
   - Skip rate limiting (can add later)
   - Focus on core functionality: Create fee with image upload

2. **Must-Have Features**:
   - ✅ JWT authentication and authorization
   - ✅ Tenant isolation (SchoolId from JWT)
   - ✅ Image upload to S3
   - ✅ Database persistence
   - ✅ Input validation
   - ✅ Error handling

3. **Nice-to-Have (if time permits)**:
   - Event publishing
   - Caching
   - Rate limiting
   - Health checks
   - Unit tests

4. **Testing Strategy**:
   - Use Postman or Swagger UI
   - Create a test JWT token with SchoolId and SchoolAdmin role
   - Test happy path first
   - Then test error scenarios

---

## Next Steps After POC

1. Add event publishing (FeeCreated event)
2. Add GET endpoints (list fees, get fee by ID)
3. Add UPDATE and DELETE endpoints
4. Add image optimization (resize, compress)
5. Add caching layer (Redis)
6. Add rate limiting
7. Add comprehensive logging and monitoring
8. Add unit and integration tests
9. Add API versioning
10. Add request/response compression

---

## References

- [ASP.NET Core Documentation](https://docs.microsoft.com/aspnet/core)
- [AWS S3 .NET SDK](https://docs.aws.amazon.com/sdk-for-net/latest/developer-guide/s3.html)
- [Entity Framework Core](https://docs.microsoft.com/ef/core)
- [FluentValidation](https://docs.fluentvalidation.net/)
- [JWT Authentication in ASP.NET Core](https://docs.microsoft.com/aspnet/core/security/authentication/jwt-authn)

