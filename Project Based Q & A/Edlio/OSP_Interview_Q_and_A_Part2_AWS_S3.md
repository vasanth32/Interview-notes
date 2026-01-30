# Edlio-like Online School Platform - Interview Q&A Part 2: AWS S3

## Question: Explain AWS S3 and How It's Used in the OSP Project

---

## **Overview Response (30 seconds)**

"AWS S3 (Simple Storage Service) is Amazon's object storage service that provides scalable, secure, and highly available storage for files and data. In the OSP project, I used S3 to store student profile photos, school logos and branding assets, uploaded documents like transcripts and certificates, generated reports and invoices as PDFs, and activity images. S3's features like versioning, lifecycle policies, and CDN integration through CloudFront helped us manage costs and improve performance for file delivery across our multi-tenant platform."

---

## **Part 1: AWS S3 High-Level Concepts**

### **What is AWS S3?**

**AWS S3 (Simple Storage Service)** is Amazon's object storage service designed to store and retrieve any amount of data from anywhere on the web.

**Key Characteristics:**
- **Object Storage**: Stores files as objects (not files in folders like traditional storage)
- **Unlimited Scalability**: Can store unlimited data
- **99.999999999% (11 9's) Durability**: Extremely reliable - data is replicated across multiple facilities
- **99.99% Availability**: Highly available with SLA guarantees
- **Pay-as-you-go**: Pay only for what you use

---

### **Core Concepts**

#### **1. Buckets**
- **What**: Containers for storing objects (like folders, but at the top level)
- **Naming**: Must be globally unique across all AWS accounts
- **Region**: Created in a specific AWS region
- **Example**: `osp-student-photos-us-east-1`

#### **2. Objects**
- **What**: Files stored in buckets (photos, documents, videos, etc.)
- **Components**:
  - **Key**: Object name/path (e.g., `schools/school-123/logo.png`)
  - **Value**: Actual file data
  - **Metadata**: Information about the object (content-type, size, etc.)
  - **Version ID**: Unique identifier for object versions

#### **3. Storage Classes**
Different storage tiers optimized for different use cases:

- **S3 Standard**: Frequently accessed data (default)
- **S3 Intelligent-Tiering**: Automatically moves data between access tiers
- **S3 Standard-IA (Infrequent Access)**: Less frequently accessed, lower cost
- **S3 One Zone-IA**: Lower cost, single availability zone
- **S3 Glacier**: Archive storage (cheapest, retrieval takes time)
- **S3 Glacier Deep Archive**: Long-term archive (cheapest, longest retrieval time)

#### **4. Access Control**
- **IAM Policies**: Control who can access buckets/objects
- **Bucket Policies**: Bucket-level access rules
- **ACLs (Access Control Lists)**: Object-level permissions
- **Pre-signed URLs**: Temporary URLs for private objects

#### **5. Features**

**Versioning:**
- Keeps multiple versions of objects
- Protects against accidental deletion
- Useful for audit trails

**Lifecycle Policies:**
- Automatically move objects to cheaper storage classes
- Delete old objects after specified time
- Reduce storage costs

**Encryption:**
- **Server-Side Encryption (SSE)**: Encrypts data at rest
  - SSE-S3: AWS-managed keys
  - SSE-KMS: AWS KMS-managed keys
  - SSE-C: Customer-provided keys
- **Client-Side Encryption**: Encrypt before uploading

**Cross-Region Replication (CRR):**
- Automatically replicate objects to another region
- Disaster recovery and compliance

**Static Website Hosting:**
- Host static websites directly from S3
- No web server needed

**Event Notifications:**
- Trigger Lambda functions, SQS queues, or SNS topics when objects are created/deleted
- Enables event-driven architectures

---

### **S3 Pricing Model**

**Storage Costs:**
- Pay per GB stored per month
- Different rates for different storage classes
- Standard: ~$0.023/GB/month
- Glacier: ~$0.004/GB/month

**Request Costs:**
- PUT requests (uploads): ~$0.005 per 1,000 requests
- GET requests (downloads): ~$0.0004 per 1,000 requests
- Data transfer OUT: Costs for data transferred out of S3

**Cost Optimization:**
- Use lifecycle policies to move old data to cheaper tiers
- Use appropriate storage classes
- Compress files before uploading
- Use CloudFront CDN to reduce data transfer costs

---

## **Part 2: S3 Use Cases in OSP Project**

### **Scenario 1: Student Profile Photo Storage**

**Business Requirement:**
- Students upload profile photos
- Photos displayed across student portal, admin portals
- Need to support multiple image sizes (thumbnail, medium, large)

**S3 Implementation:**

**Bucket Structure:**
```
osp-student-photos/
├── schools/
│   ├── school-123/
│   │   ├── students/
│   │   │   ├── student-456/
│   │   │   │   ├── original/
│   │   │   │   │   └── photo.jpg
│   │   │   │   ├── thumbnails/
│   │   │   │   │   └── photo-150x150.jpg
│   │   │   │   └── medium/
│   │   │   │       └── photo-500x500.jpg
```



## **Complete Implementation Guide: Student Profile Photo Storage**

This section provides a comprehensive, step-by-step implementation guide for the Student Profile Photo Storage flow, covering everything from AWS cloud setup to API-side implementation, including common issues and troubleshooting.

---

### **Part 1: Complete Flow Overview**

**End-to-End Flow:**

```
1. Student uploads photo via Student Portal
   ↓
2. Frontend sends photo to API Gateway
   ↓
3. API Gateway routes to Student Service
   ↓
4. Student Service validates photo (size, type, dimensions)
   ↓
5. Student Service uploads original photo to S3
   ↓
6. S3 event triggers Lambda function (or background job)
   ↓
7. Lambda/Job generates thumbnails (150x150, 500x500)
   ↓
8. Thumbnails uploaded back to S3
   ↓
9. Student Service generates pre-signed URLs
   ↓
10. URLs returned to frontend
   ↓
11. Frontend displays photo using pre-signed URL
```

**Key Components:**
- **S3 Bucket**: Stores original photos and thumbnails
- **IAM Roles**: Grants services permission to access S3
- **Lambda Function**: Generates thumbnails automatically (optional)
- **Student Service**: Handles upload/download logic
- **Pre-signed URLs**: Secure temporary access to private photos

---

### **Part 2: Cloud-Side Setup (Complete Steps)**

#### **Step 1: Create S3 Bucket**

```bash
# Create bucket with versioning enabled
aws s3 mb s3://osp-student-photos-us-east-1 \
  --region us-east-1

# Verify bucket creation
aws s3 ls | grep osp-student-photos
```

**Explanation:**
- **Bucket Name**: Must be globally unique across all AWS accounts
- **Region**: Choose based on your application's primary region
- **Naming Convention**: Include project prefix and region for clarity

#### **Step 2: Configure Bucket Versioning**

```bash
# Enable versioning to protect against accidental deletion
aws s3api put-bucket-versioning \
  --bucket osp-student-photos-us-east-1 \
  --versioning-configuration Status=Enabled

# Verify versioning
aws s3api get-bucket-versioning \
  --bucket osp-student-photos-us-east-1
```

**Why Versioning?**
- **Accidental Deletion Protection**: Can restore previous versions
- **Photo Update History**: Track when photos were changed
- **Audit Trail**: Compliance and debugging

#### **Step 3: Enable Server-Side Encryption**

```bash
# Enable AES256 encryption (AWS-managed keys)
aws s3api put-bucket-encryption \
  --bucket osp-student-photos-us-east-1 \
  --server-side-encryption-configuration '{
    "Rules": [{
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      },
      "BucketKeyEnabled": true
    }]
  }'

# Verify encryption
aws s3api get-bucket-encryption \
  --bucket osp-student-photos-us-east-1
```

**Why Encryption?**
- **Security**: Protects student photos at rest
- **Compliance**: Required for PII (Personally Identifiable Information)
- **Best Practice**: Encrypt all sensitive data

#### **Step 4: Configure Bucket Policy (Private Access)**

```bash
# Create bucket policy JSON file
cat > bucket-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowApplicationRoleAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::ACCOUNT_ID:role/OSPStudentServiceRole"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetObjectVersion"
      ],
      "Resource": "arn:aws:s3:::osp-student-photos-us-east-1/*"
    },
    {
      "Sid": "DenyPublicAccess",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::osp-student-photos-us-east-1",
        "arn:aws:s3:::osp-student-photos-us-east-1/*"
      ],
      "Condition": {
        "Bool": {
          "aws:PrincipalServiceName": "false"
        }
      }
    }
  ]
}
EOF

# Apply bucket policy
aws s3api put-bucket-policy \
  --bucket osp-student-photos-us-east-1 \
  --policy file://bucket-policy.json

# Verify policy
aws s3api get-bucket-policy \
  --bucket osp-student-photos-us-east-1
```

**Explanation:**
- **AllowApplicationRoleAccess**: Only your application role can access
- **DenyPublicAccess**: Explicitly deny public access (security best practice)
- **GetObjectVersion**: Needed for versioning support

#### **Step 5: Block Public Access (Additional Security)**

```bash
# Block all public access
aws s3api put-public-access-block \
  --bucket osp-student-photos-us-east-1 \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Verify
aws s3api get-public-access-block \
  --bucket osp-student-photos-us-east-1
```

**Why Block Public Access?**
- **Security**: Prevents accidental public exposure
- **Compliance**: Required for PII data
- **Best Practice**: Private by default

#### **Step 6: Create IAM Role for Student Service**

```bash
# Create trust policy (allows EC2/ECS to assume role)
cat > trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

# Create IAM role
aws iam create-role \
  --role-name OSPStudentServiceRole \
  --assume-role-policy-document file://trust-policy.json

# Create policy for S3 access
cat > s3-access-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:GetObjectVersion",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::osp-student-photos-us-east-1",
        "arn:aws:s3:::osp-student-photos-us-east-1/*"
      ]
    }
  ]
}
EOF

# Create IAM policy
aws iam create-policy \
  --policy-name StudentPhotoS3AccessPolicy \
  --policy-document file://s3-access-policy.json

# Attach policy to role
aws iam attach-role-policy \
  --role-name OSPStudentServiceRole \
  --policy-arn arn:aws:iam::ACCOUNT_ID:policy/StudentPhotoS3AccessPolicy
```

**Explanation:**
- **Trust Policy**: Defines who can assume this role (EC2, ECS, Lambda)
- **S3 Access Policy**: Grants specific S3 permissions
- **Least Privilege**: Only necessary permissions granted

#### **Step 7: Configure Lifecycle Policy (Cost Optimization)**

```bash
# Create lifecycle policy to move old photos to cheaper storage
cat > lifecycle-policy.json <<EOF
{
  "Rules": [
    {
      "Id": "MoveOldPhotosToIA",
      "Status": "Enabled",
      "Prefix": "schools/",
      "Transitions": [
        {
          "Days": 90,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 365,
          "StorageClass": "GLACIER"
        }
      ]
    }
  ]
}
EOF

# Apply lifecycle policy
aws s3api put-bucket-lifecycle-configuration \
  --bucket osp-student-photos-us-east-1 \
  --lifecycle-configuration file://lifecycle-policy.json

# Verify
aws s3api get-bucket-lifecycle-configuration \
  --bucket osp-student-photos-us-east-1
```

**Why Lifecycle Policy?**
- **Cost Savings**: Move old photos to cheaper storage (40-68% savings)
- **Automatic**: No manual intervention needed
- **Optimization**: Right storage class for access patterns

#### **Step 8: Set Up S3 Event Notification (Optional - for Thumbnail Generation)**

```bash
# Create Lambda function trigger configuration
cat > event-config.json <<EOF
{
  "LambdaFunctionConfigurations": [
    {
      "Id": "GenerateThumbnails",
      "LambdaFunctionArn": "arn:aws:lambda:us-east-1:ACCOUNT_ID:function:GenerateThumbnails",
      "Events": ["s3:ObjectCreated:*"],
      "Filter": {
        "Key": {
          "FilterRules": [
            {
              "Name": "prefix",
              "Value": "schools/"
            },
            {
              "Name": "suffix",
              "Value": "/original/photo.jpg"
            }
          ]
        }
      }
    }
  ]
}
EOF

# Configure event notification
aws s3api put-bucket-notification-configuration \
  --bucket osp-student-photos-us-east-1 \
  --notification-configuration file://event-config.json
```

**Why S3 Events?**
- **Automation**: Automatically generate thumbnails when photo uploaded
- **Decoupling**: Lambda handles image processing separately
- **Scalability**: Process thumbnails asynchronously

---

### **Part 3: API-Side Implementation (Complete Code)**

#### **Step 1: Install Required NuGet Packages**

```bash
# In Student Service project
dotnet add package AWSSDK.S3
dotnet add package Microsoft.Extensions.Configuration
dotnet add package Microsoft.Extensions.Configuration.AWS
dotnet add package SixLabors.ImageSharp  # For image processing
```

#### **Step 2: Configure appsettings.json**

```json
{
  "AWS": {
    "Region": "us-east-1",
    "S3": {
      "StudentPhotosBucket": "osp-student-photos-us-east-1",
      "PreSignedUrlExpirationHours": 1
    }
  },
  "PhotoUpload": {
    "MaxFileSizeMB": 5,
    "AllowedContentTypes": ["image/jpeg", "image/png", "image/jpg"],
    "MaxWidth": 2000,
    "MaxHeight": 2000,
    "ThumbnailSizes": [
      { "Name": "thumbnail", "Width": 150, "Height": 150 },
      { "Name": "medium", "Width": 500, "Height": 500 }
    ]
  }
}
```

#### **Step 3: Create Service Interface**

```csharp
// Services/IStudentPhotoService.cs
namespace StudentService.Services
{
    public interface IStudentPhotoService
    {
        Task<PhotoUploadResult> UploadStudentPhotoAsync(
            string studentId, 
            string schoolId, 
            Stream photoStream,
            string contentType,
            CancellationToken cancellationToken = default);
        
        Task<string> GetStudentPhotoUrlAsync(
            string studentId, 
            string schoolId, 
            string size = "medium",
            int expirationHours = 1);
        
        Task<bool> DeleteStudentPhotoAsync(
            string studentId, 
            string schoolId);
        
        Task<bool> PhotoExistsAsync(
            string studentId, 
            string schoolId, 
            string size = "original");
    }

    public class PhotoUploadResult
    {
        public string PhotoUrl { get; set; }
        public string OriginalKey { get; set; }
        public long FileSize { get; set; }
        public string ContentType { get; set; }
        public Dictionary<string, string> ThumbnailUrls { get; set; }
    }
}
```

#### **Step 4: Implement Photo Service**

```csharp
// Services/StudentPhotoService.cs
using Amazon.S3;
using Amazon.S3.Model;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;

namespace StudentService.Services
{
    public class StudentPhotoService : IStudentPhotoService
    {
        private readonly IAmazonS3 _s3Client;
        private readonly string _bucketName;
        private readonly IConfiguration _configuration;
        private readonly ILogger<StudentPhotoService> _logger;
        private readonly int _preSignedUrlExpirationHours;
        private readonly long _maxFileSizeBytes;
        private readonly string[] _allowedContentTypes;

        public StudentPhotoService(
            IAmazonS3 s3Client,
            IConfiguration configuration,
            ILogger<StudentPhotoService> logger)
        {
            _s3Client = s3Client;
            _bucketName = configuration["AWS:S3:StudentPhotosBucket"];
            _configuration = configuration;
            _logger = logger;
            _preSignedUrlExpirationHours = 
                int.Parse(configuration["AWS:S3:PreSignedUrlExpirationHours"] ?? "1");
            _maxFileSizeBytes = 
                long.Parse(configuration["PhotoUpload:MaxFileSizeMB"] ?? "5") * 1024 * 1024;
            _allowedContentTypes = 
                configuration.GetSection("PhotoUpload:AllowedContentTypes").Get<string[]>() 
                ?? new[] { "image/jpeg", "image/png" };
        }

        public async Task<PhotoUploadResult> UploadStudentPhotoAsync(
            string studentId,
            string schoolId,
            Stream photoStream,
            string contentType,
            CancellationToken cancellationToken = default)
        {
            try
            {
                // 1. Validate input
                ValidatePhotoUpload(photoStream, contentType);

                // 2. Read stream into memory for processing
                using var memoryStream = new MemoryStream();
                await photoStream.CopyToAsync(memoryStream, cancellationToken);
                memoryStream.Position = 0;

                // 3. Validate and process image
                using var image = await Image.LoadAsync(memoryStream, cancellationToken);
                ValidateImageDimensions(image);

                // 4. Resize if needed (maintain aspect ratio)
                var maxWidth = int.Parse(_configuration["PhotoUpload:MaxWidth"] ?? "2000");
                var maxHeight = int.Parse(_configuration["PhotoUpload:MaxHeight"] ?? "2000");
                
                if (image.Width > maxWidth || image.Height > maxHeight)
                {
                    image.Mutate(x => x.Resize(new ResizeOptions
                    {
                        Size = new Size(maxWidth, maxHeight),
                        Mode = ResizeMode.Max
                    }));
                }

                // 5. Save processed image
                using var processedStream = new MemoryStream();
                await image.SaveAsJpegAsync(processedStream, cancellationToken);
                processedStream.Position = 0;

                // 6. Upload original to S3
                var originalKey = $"schools/{schoolId}/students/{studentId}/original/photo.jpg";
                await UploadToS3Async(
                    originalKey,
                    processedStream,
                    "image/jpeg",
                    cancellationToken);

                _logger.LogInformation(
                    "Student photo uploaded. StudentId: {StudentId}, SchoolId: {SchoolId}, Size: {Size} bytes",
                    studentId,
                    schoolId,
                    processedStream.Length);

                // 7. Generate thumbnails (if not using Lambda)
                var thumbnailUrls = await GenerateThumbnailsAsync(
                    studentId,
                    schoolId,
                    processedStream,
                    cancellationToken);

                // 8. Generate pre-signed URL for original
                var photoUrl = await GeneratePreSignedUrlAsync(
                    originalKey,
                    TimeSpan.FromHours(_preSignedUrlExpirationHours));

                return new PhotoUploadResult
                {
                    PhotoUrl = photoUrl,
                    OriginalKey = originalKey,
                    FileSize = processedStream.Length,
                    ContentType = "image/jpeg",
                    ThumbnailUrls = thumbnailUrls
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Failed to upload student photo. StudentId: {StudentId}, SchoolId: {SchoolId}",
                    studentId,
                    schoolId);
                throw;
            }
        }

        public async Task<string> GetStudentPhotoUrlAsync(
            string studentId,
            string schoolId,
            string size = "medium",
            int expirationHours = 1)
        {
            try
            {
                var key = $"schools/{schoolId}/students/{studentId}/{size}/photo.jpg";
                
                // Check if photo exists
                var exists = await PhotoExistsAsync(studentId, schoolId, size);
                if (!exists && size != "original")
                {
                    // Fallback to original if thumbnail doesn't exist
                    key = $"schools/{schoolId}/students/{studentId}/original/photo.jpg";
                }

                return await GeneratePreSignedUrlAsync(
                    key,
                    TimeSpan.FromHours(expirationHours));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Failed to get student photo URL. StudentId: {StudentId}, Size: {Size}",
                    studentId,
                    size);
                throw;
            }
        }

        public async Task<bool> DeleteStudentPhotoAsync(
            string studentId,
            string schoolId)
        {
            try
            {
                var sizes = new[] { "original", "thumbnail", "medium" };
                var deleted = true;

                foreach (var size in sizes)
                {
                    var key = $"schools/{schoolId}/students/{studentId}/{size}/photo.jpg";
                    try
                    {
                        await _s3Client.DeleteObjectAsync(
                            _bucketName,
                            key);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex,
                            "Failed to delete photo. Key: {Key}",
                            key);
                        deleted = false;
                    }
                }

                _logger.LogInformation(
                    "Student photos deleted. StudentId: {StudentId}, SchoolId: {SchoolId}",
                    studentId,
                    schoolId);

                return deleted;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Failed to delete student photos. StudentId: {StudentId}",
                    studentId);
                throw;
            }
        }

        public async Task<bool> PhotoExistsAsync(
            string studentId,
            string schoolId,
            string size = "original")
        {
            try
            {
                var key = $"schools/{schoolId}/students/{studentId}/{size}/photo.jpg";
                
                var request = new GetObjectMetadataRequest
                {
                    BucketName = _bucketName,
                    Key = key
                };

                await _s3Client.GetObjectMetadataAsync(request);
                return true;
            }
            catch (AmazonS3Exception ex) when (ex.StatusCode == System.Net.HttpStatusCode.NotFound)
            {
                return false;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex,
                    "Error checking photo existence. Key: {Key}",
                    $"schools/{schoolId}/students/{studentId}/{size}/photo.jpg");
                throw;
            }
        }

        private void ValidatePhotoUpload(Stream photoStream, string contentType)
        {
            // Validate content type
            if (!_allowedContentTypes.Contains(contentType.ToLower()))
            {
                throw new ArgumentException(
                    $"Invalid content type. Allowed types: {string.Join(", ", _allowedContentTypes)}");
            }

            // Validate file size
            if (photoStream.Length > _maxFileSizeBytes)
            {
                throw new ArgumentException(
                    $"File size exceeds maximum allowed size of {_maxFileSizeBytes / 1024 / 1024} MB");
            }

            if (photoStream.Length == 0)
            {
                throw new ArgumentException("File is empty");
            }
        }

        private void ValidateImageDimensions(Image image)
        {
            var minWidth = 100;
            var minHeight = 100;
            var maxWidth = int.Parse(_configuration["PhotoUpload:MaxWidth"] ?? "2000");
            var maxHeight = int.Parse(_configuration["PhotoUpload:MaxHeight"] ?? "2000");

            if (image.Width < minWidth || image.Height < minHeight)
            {
                throw new ArgumentException(
                    $"Image dimensions must be at least {minWidth}x{minHeight} pixels");
            }

            if (image.Width > maxWidth || image.Height > maxHeight)
            {
                // Will be resized, but log warning
                _logger.LogWarning(
                    "Image dimensions exceed maximum. Will be resized. Width: {Width}, Height: {Height}",
                    image.Width,
                    image.Height);
            }
        }

        private async Task UploadToS3Async(
            string key,
            Stream stream,
            string contentType,
            CancellationToken cancellationToken)
        {
            var request = new PutObjectRequest
            {
                BucketName = _bucketName,
                Key = key,
                InputStream = stream,
                ContentType = contentType,
                ServerSideEncryptionMethod = ServerSideEncryptionMethod.AES256,
                CannedACL = S3CannedACL.Private,
                Metadata =
                {
                    ["uploaded-at"] = DateTime.UtcNow.ToString("O")
                }
            };

            await _s3Client.PutObjectAsync(request, cancellationToken);
        }

        private async Task<Dictionary<string, string>> GenerateThumbnailsAsync(
            string studentId,
            string schoolId,
            Stream originalStream,
            CancellationToken cancellationToken)
        {
            var thumbnailUrls = new Dictionary<string, string>();
            var thumbnailSizes = _configuration.GetSection("PhotoUpload:ThumbnailSizes").GetChildren();

            originalStream.Position = 0;
            using var image = await Image.LoadAsync(originalStream, cancellationToken);

            foreach (var sizeConfig in thumbnailSizes)
            {
                var sizeName = sizeConfig["Name"];
                var width = int.Parse(sizeConfig["Width"]);
                var height = int.Parse(sizeConfig["Height"]);

                // Create thumbnail
                using var thumbnail = image.Clone();
                thumbnail.Mutate(x => x.Resize(new ResizeOptions
                {
                    Size = new Size(width, height),
                    Mode = ResizeMode.Crop
                }));

                // Save thumbnail
                using var thumbnailStream = new MemoryStream();
                await thumbnail.SaveAsJpegAsync(thumbnailStream, cancellationToken);
                thumbnailStream.Position = 0;

                // Upload thumbnail to S3
                var thumbnailKey = $"schools/{schoolId}/students/{studentId}/{sizeName}/photo.jpg";
                await UploadToS3Async(
                    thumbnailKey,
                    thumbnailStream,
                    "image/jpeg",
                    cancellationToken);

                // Generate pre-signed URL
                var thumbnailUrl = await GeneratePreSignedUrlAsync(
                    thumbnailKey,
                    TimeSpan.FromHours(_preSignedUrlExpirationHours));

                thumbnailUrls[sizeName] = thumbnailUrl;
            }

            return thumbnailUrls;
        }

        private async Task<string> GeneratePreSignedUrlAsync(
            string key,
            TimeSpan expiration)
        {
            var request = new GetPreSignedUrlRequest
            {
                BucketName = _bucketName,
                Key = key,
                Verb = HttpVerb.GET,
                Expires = DateTime.UtcNow.Add(expiration)
            };

            return await _s3Client.GetPreSignedURLAsync(request);
        }
    }
}
```

#### **Step 5: Create Controller**

```csharp
// Controllers/StudentPhotoController.cs
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StudentService.Services;

namespace StudentService.Controllers
{
    [ApiController]
    [Route("api/students/{studentId}/photos")]
    [Authorize]
    public class StudentPhotoController : ControllerBase
    {
        private readonly IStudentPhotoService _photoService;
        private readonly ILogger<StudentPhotoController> _logger;

        public StudentPhotoController(
            IStudentPhotoService photoService,
            ILogger<StudentPhotoController> logger)
        {
            _photoService = photoService;
            _logger = logger;
        }

        [HttpPost]
        public async Task<IActionResult> UploadPhoto(
            string studentId,
            [FromForm] IFormFile photo,
            CancellationToken cancellationToken)
        {
            try
            {
                // Validate student can upload their own photo
                var currentUserId = User.FindFirst("userId")?.Value;
                if (currentUserId != studentId && !User.IsInRole("SchoolAdmin"))
                {
                    return Forbid("You can only upload your own photo");
                }

                if (photo == null || photo.Length == 0)
                {
                    return BadRequest("No file uploaded");
                }

                // Get school ID from user claims
                var schoolId = User.FindFirst("schoolId")?.Value;
                if (string.IsNullOrEmpty(schoolId))
                {
                    return BadRequest("School ID not found");
                }

                using var stream = photo.OpenReadStream();
                var result = await _photoService.UploadStudentPhotoAsync(
                    studentId,
                    schoolId,
                    stream,
                    photo.ContentType,
                    cancellationToken);

                return Ok(new
                {
                    PhotoUrl = result.PhotoUrl,
                    ThumbnailUrls = result.ThumbnailUrls,
                    FileSize = result.FileSize
                });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to upload photo for student {StudentId}", studentId);
                return StatusCode(500, "Failed to upload photo");
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetPhoto(
            string studentId,
            [FromQuery] string size = "medium",
            [FromQuery] int expirationHours = 1)
        {
            try
            {
                var schoolId = User.FindFirst("schoolId")?.Value;
                if (string.IsNullOrEmpty(schoolId))
                {
                    return BadRequest("School ID not found");
                }

                var url = await _photoService.GetStudentPhotoUrlAsync(
                    studentId,
                    schoolId,
                    size,
                    expirationHours);

                return Ok(new { PhotoUrl = url });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to get photo URL for student {StudentId}", studentId);
                return StatusCode(500, "Failed to get photo URL");
            }
        }

        [HttpDelete]
        public async Task<IActionResult> DeletePhoto(string studentId)
        {
            try
            {
                var currentUserId = User.FindFirst("userId")?.Value;
                if (currentUserId != studentId && !User.IsInRole("SchoolAdmin"))
                {
                    return Forbid("You can only delete your own photo");
                }

                var schoolId = User.FindFirst("schoolId")?.Value;
                if (string.IsNullOrEmpty(schoolId))
                {
                    return BadRequest("School ID not found");
                }

                var deleted = await _photoService.DeleteStudentPhotoAsync(studentId, schoolId);
                
                return deleted 
                    ? Ok(new { Message = "Photo deleted successfully" })
                    : StatusCode(500, "Failed to delete some photo sizes");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to delete photo for student {StudentId}", studentId);
                return StatusCode(500, "Failed to delete photo");
            }
        }
    }
}
```

#### **Step 6: Register Services**

```csharp
// Program.cs
using Amazon.S3;
using StudentService.Services;

var builder = WebApplication.CreateBuilder(args);

// Add AWS S3 client
builder.Services.AddAWSService<IAmazonS3>();

// Register photo service
builder.Services.AddScoped<IStudentPhotoService, StudentPhotoService>();

// ... rest of configuration
```

---


### **Architecture Decision: Direct Upload vs Pre-Signed URL Upload**

#### **What is Direct Upload?**

**Direct Upload (Server-Side Upload):**
- Frontend sends photo to your API server
- API server receives photo, processes it, then uploads to S3
- Photo flows through your application server

**Flow:**
```
Frontend → API Server → Process/Validate → S3
```

#### **What is Pre-Signed URL Upload?**

**Pre-Signed URL Upload (Client-Side Upload):**
- Frontend requests pre-signed URL from API server
- API server generates pre-signed URL and returns to frontend
- Frontend uploads directly to S3 using pre-signed URL
- Photo bypasses your application server

**Flow:**
```
Frontend → API Server (get pre-signed URL) → Frontend → S3 (direct upload)
```

---

#### **Detailed Comparison**

| Aspect | Direct Upload | Pre-Signed URL Upload |
|--------|---------------|----------------------|
| **Server Load** | High (photo passes through server) | Low (only URL generation) |
| **Bandwidth** | Uses server bandwidth | Uses client bandwidth |
| **Scalability** | Limited by server capacity | Highly scalable |
| **Cost** | Higher (server processing) | Lower (no server processing) |
| **Latency** | Higher (server processing time) | Lower (direct to S3) |
| **Security** | Server validates before upload | Validation happens after upload |
| **File Size Limits** | Limited by server config | Limited by S3 (5TB max) |
| **Processing** | Can process before upload | Must process after upload |
| **Error Handling** | Server handles errors | Client handles upload errors |
| **Progress Tracking** | Server-side tracking | Client-side tracking |

---

#### **Which is Best for Student Photo Upload Scenario?**

**Recommendation: Pre-Signed URL Upload (with validation)**

**Why Pre-Signed URL is Better:**

1. **Scalability**
   - Student photos don't need server processing before upload
   - Reduces server load significantly
   - Can handle thousands of concurrent uploads

2. **Performance**
   - Faster uploads (direct to S3, no server bottleneck)
   - Better user experience (no server processing delay)
   - Lower latency

3. **Cost Efficiency**
   - Reduces server compute costs
   - Reduces server bandwidth costs
   - Only pay for S3 storage and requests

4. **Large File Support**
   - Can handle large photos without server memory issues
   - Supports multipart upload for very large files
   - No server timeout issues

**However, Add Validation:**

Even with pre-signed URL upload, you should:
- Validate file size before generating URL
- Validate file type before generating URL
- Set expiration time on pre-signed URL (15 minutes)
- Process/validate after upload completes (via S3 event)

---

#### **Hybrid Approach (Recommended)**

**Best Practice: Pre-Signed URL with Post-Upload Validation**

**Flow:**
```
1. Frontend requests upload URL → API validates request → Returns pre-signed URL
2. Frontend uploads directly to S3 using pre-signed URL
3. Frontend notifies API server when upload completes
4. API server validates file (size, type, content)
5. API server processes image (resize, generate thumbnails)
6. API server updates database with photo metadata
```

**Benefits:**
- Fast upload (direct to S3)
- Server validation (security)
- Image processing (thumbnails)
- Database update (metadata)

---

#### **Implementation: Pre-Signed URL Upload**

**Step 1: API Endpoint to Generate Pre-Signed URL**

```csharp
// Controllers/StudentPhotoController.cs
[HttpPost("{studentId}/photos/upload-url")]
public async Task<IActionResult> GetUploadUrl(
    string studentId,
    [FromBody] PhotoUploadRequest request)
{
    try
    {
        // 1. Validate request
        ValidateUploadRequest(request);

        // 2. Get school ID
        var schoolId = User.FindFirst("schoolId")?.Value;
        if (string.IsNullOrEmpty(schoolId))
        {
            return BadRequest("School ID not found");
        }

        // 3. Generate unique file name
        var fileName = $"{Guid.NewGuid()}.jpg";
        var key = $"schools/{schoolId}/students/{studentId}/original/{fileName}";

        // 4. Generate pre-signed URL for PUT (upload)
        var uploadUrl = await _photoService.GenerateUploadUrlAsync(
            key,
            request.ContentType,
            request.FileSize,
            TimeSpan.FromMinutes(15)); // 15 minute expiration

        // 5. Store upload metadata in database (for validation later)
        await _photoService.SaveUploadMetadataAsync(new UploadMetadata
        {
            StudentId = studentId,
            SchoolId = schoolId,
            S3Key = key,
            FileName = fileName,
            ContentType = request.ContentType,
            FileSize = request.FileSize,
            Status = "Pending",
            CreatedAt = DateTime.UtcNow
        });

        return Ok(new
        {
            UploadUrl = uploadUrl,
            Key = key,
            ExpiresIn = 900 //15 minutes in seconds
        });
    }
    catch (ArgumentException ex)
    {
        return BadRequest(ex.Message);
    }
}

private void ValidateUploadRequest(PhotoUploadRequest request)
{
    // Validate file size (max 5MB)
    if (request.FileSize > 5 * 1024 * 1024)
    {
        throw new ArgumentException("File size exceeds 5MB limit");
    }

    // Validate content type
    var allowedTypes = new[] { "image/jpeg", "image/png", "image/jpg" };
    if (!allowedTypes.Contains(request.ContentType.ToLower()))
    {
        throw new ArgumentException("Invalid file type. Only JPEG and PNG allowed");
    }
}
```

**Step 2: Service Method to Generate Upload URL**

```csharp
// Services/StudentPhotoService.cs
public async Task<string> GenerateUploadUrlAsync(
    string key,
    string contentType,
    long fileSize,
    TimeSpan expiration)
{
    try
    {
        // Validate file size before generating URL
        if (fileSize > _maxFileSizeBytes)
        {
            throw new ArgumentException(
                $"File size exceeds maximum allowed size of {_maxFileSizeBytes / 1024 / 1024} MB");
        }

        // Generate pre-signed URL for PUT operation
        var request = new GetPreSignedUrlRequest
        {
            BucketName = _bucketName,
            Key = key,
            Verb = HttpVerb.PUT, // PUT for upload
            Expires = DateTime.UtcNow.Add(expiration),
            ContentType = contentType,
            ServerSideEncryptionMethod = ServerSideEncryptionMethod.AES256
        };

        // Add conditions to enforce file size and content type
        request.Headers.Add("x-amz-server-side-encryption", "AES256");
        
        var url = await _s3Client.GetPreSignedURLAsync(request);

        _logger.LogInformation(
            "Generated upload URL. Key: {Key}, Expires: {Expires}",
            key,
            DateTime.UtcNow.Add(expiration));

        return url;
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Failed to generate upload URL. Key: {Key}", key);
        throw;
    }
}
```

**Step 3: Frontend Upload Implementation**

```javascript
// Frontend: upload-photo.js
async function uploadStudentPhoto(studentId, file) {
    try {
        // 1. Validate file on client side
        if (file.size > 5 * 1024 * 1024) {
            throw new Error('File size exceeds 5MB');
        }

        if (!file.type.startsWith('image/')) {
            throw new Error('Invalid file type');
        }

        // 2. Request pre-signed URL from API
        const response = await fetch(`/api/students/${studentId}/photos/upload-url`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
                contentType: file.type,
                fileSize: file.size
            })
        });

        const { uploadUrl, key, expiresIn } = await response.json();

        // 3. Upload directly to S3 using pre-signed URL
        const uploadResponse = await fetch(uploadUrl, {
            method: 'PUT',
            headers: {
                'Content-Type': file.type,
                'x-amz-server-side-encryption': 'AES256'
            },
            body: file
        });

        if (!uploadResponse.ok) {
            throw new Error('Upload failed');
        }

        // 4. Notify API server that upload completed
        await fetch(`/api/students/${studentId}/photos/upload-complete`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
                key: key,
                fileSize: file.size,
                contentType: file.type
            })
        });

        console.log('Photo uploaded successfully');
        return key;
    } catch (error) {
        console.error('Upload failed:', error);
        throw error;
    }
}
```

**Step 4: Post-Upload Validation Endpoint**

```csharp
// Controllers/StudentPhotoController.cs
[HttpPost("{studentId}/photos/upload-complete")]
public async Task<IActionResult> UploadComplete(
    string studentId,
    [FromBody] UploadCompleteRequest request)
{
    try
    {
        var schoolId = User.FindFirst("schoolId")?.Value;

        // 1. Verify file exists in S3
        var exists = await _photoService.PhotoExistsByKeyAsync(request.Key);
        if (!exists)
        {
            return BadRequest("File not found in S3");
        }

        // 2. Download and validate file
        var fileStream = await _photoService.DownloadPhotoAsync(request.Key);
        
        // Validate file content (not just extension)
        using var image = await Image.LoadAsync(fileStream);
        
        // Validate dimensions
        if (image.Width < 100 || image.Height < 100)
        {
            // Delete invalid file
            await _photoService.DeletePhotoByKeyAsync(request.Key);
            return BadRequest("Image dimensions too small");
        }

        // 3. Process image (resize, generate thumbnails)
        await _photoService.ProcessUploadedPhotoAsync(
            studentId,
            schoolId,
            request.Key,
            image);

        // 4. Update database
        await _photoService.UpdateUploadStatusAsync(request.Key, "Completed");

        return Ok(new { Message = "Photo processed successfully" });
    }
    catch (Exception ex)
    {
        _logger.LogError(ex, "Failed to process uploaded photo");
        return StatusCode(500, "Failed to process photo");
    }
}
```

---

#### **When to Use Direct Upload Instead?**

**Use Direct Upload When:**

1. **Heavy Processing Required Before Upload**
   - Need to compress/transform before storing
   - Need to extract metadata before upload
   - Need to validate content before upload

2. **Small Files (< 1MB)**
   - Overhead of pre-signed URL not worth it
   - Server can handle easily

3. **Strict Security Requirements**
   - Need to scan files for viruses/malware
   - Need to inspect content before storage
   - Compliance requires server-side validation

4. **Simple Architecture**
   - Small application, low traffic
   - Don't need scalability benefits

---

#### **Summary: Recommendation for Student Photos**

**Use Pre-Signed URL Upload because:**

✅ **Scalability**: Handle thousands of concurrent uploads  
✅ **Performance**: Faster uploads, better UX  
✅ **Cost**: Lower server costs  
✅ **Large Files**: Support large photos without server issues  
✅ **Bandwidth**: Client bandwidth, not server bandwidth  

**With These Safeguards:**

✅ **Pre-Upload Validation**: Validate size/type before generating URL  
✅ **Post-Upload Validation**: Verify file content after upload  
✅ **Short Expiration**: 15-minute URL expiration  
✅ **Processing**: Generate thumbnails after upload (via Lambda or background job)  
✅ **Database Tracking**: Track uploads in database for audit  

**Final Answer: Pre-Signed URL Upload is best for student photo scenario.**

---



### **Part 4: Interview Q&A - Student Photo Storage**

#### **Q1: Why use S3 instead of storing photos in the database?**

**Answer:**
- **Scalability**: S3 scales infinitely; databases have BLOB storage limits and performance issues
- **Cost**: S3 costs ~$0.023/GB/month; database storage is more expensive
- **Performance**: S3 optimized for file storage; databases optimized for structured data
- **Separation**: Keep files separate from transactional data
- **Features**: S3 provides versioning, lifecycle policies, CDN integration
- **Database Size**: Storing photos in DB increases DB size, slows backups, affects performance

**Example**: If you have 10,000 students with 2MB photos each = 20GB. In S3, this costs ~$0.46/month. In database, it increases backup time, query performance, and storage costs significantly.

#### **Q2: How do you ensure security for student photos?**

**Answer:**
- **Private Buckets**: Buckets are private by default (block public access)
- **IAM Roles**: Services access S3 via IAM roles (least privilege principle)
- **Pre-signed URLs**: Generate temporary URLs (1-hour expiry) instead of direct access
- **Encryption**: Enable server-side encryption (SSE-S3 or SSE-KMS) at rest
- **Bucket Policies**: Restrict access to specific IAM roles only
- **Access Logging**: Enable S3 access logging for audit trails
- **Versioning**: Protect against accidental deletion or malicious changes

**Security Layers:**
1. Network: VPC endpoints for private access
2. Authentication: IAM roles for service access
3. Authorization: Bucket policies restrict access
4. Encryption: Data encrypted at rest
5. Access: Pre-signed URLs for temporary access

#### **Q3: How do you handle large file uploads?**

**Answer:**
- **Multipart Upload**: For files >100MB, use S3 multipart upload API
- **Progress Tracking**: Show upload progress to users (chunk-based uploads)
- **Resumable Uploads**: Handle network interruptions (save upload ID)
- **Validation**: Validate file size, type, dimensions before upload
- **Async Processing**: Upload to S3 first, then process thumbnails asynchronously
- **Timeout Handling**: Set appropriate timeouts for large files

**Implementation Example:**
```csharp
// For files > 100MB, use multipart upload
if (fileSize > 100 * 1024 * 1024)
{
    var initiateRequest = new InitiateMultipartUploadRequest
    {
        BucketName = _bucketName,
        Key = key,
        ContentType = contentType
    };
    // ... multipart upload logic
}
```

#### **Q4: How do you optimize costs?**

**Answer:**
- **Lifecycle Policies**: Automatically move old photos to cheaper storage classes
  - After 90 days: Move to Standard-IA (40% cheaper)
  - After 1 year: Move to Glacier (68% cheaper)
- **Storage Classes**: Use appropriate class for access pattern
- **Compression**: Compress images before uploading (reduce file size)
- **Delete Old Versions**: Lifecycle policy to delete old versions after X days
- **CloudFront CDN**: Use CDN for frequently accessed photos (reduce data transfer costs)

**Cost Example:**
- 10,000 photos × 2MB = 20GB
- Standard: $0.46/month
- Standard-IA (after 90 days): $0.28/month (40% savings)
- Glacier (after 1 year): $0.15/month (68% savings)

#### **Q5: How do you handle thumbnail generation?**

**Answer:**
- **Option 1: Synchronous** (current implementation)
  - Generate thumbnails during upload
  - Pros: Immediate availability
  - Cons: Slower upload, blocks API response
  
- **Option 2: Asynchronous (Lambda)**
  - S3 event triggers Lambda function
  - Lambda generates thumbnails
  - Pros: Fast upload, non-blocking
  - Cons: Thumbnails available after delay
  
- **Option 3: Background Job**
  - Upload original, queue thumbnail generation
  - Background worker processes queue
  - Pros: Control over processing, retry logic
  - Cons: Requires queue infrastructure

**Best Practice**: Use Lambda for automatic thumbnail generation (decoupled, scalable).

#### **Q6: What happens if a pre-signed URL expires?**

**Answer:**
- **Expiration**: Pre-signed URLs expire after specified time (default 1 hour)
- **Regeneration**: Frontend requests new URL from API when expired
- **Error Handling**: API returns 403 Forbidden; frontend handles gracefully
- **Refresh Strategy**: Frontend can request new URL before expiration
- **Caching**: Frontend can cache URL until expiration

**Implementation:**
```javascript
// Frontend code
async function getPhotoUrl(studentId, size) {
    const cached = localStorage.getItem(`photo-${studentId}-${size}`);
    if (cached) {
        const { url, expires } = JSON.parse(cached);
        if (new Date(expires) > new Date()) {
            return url; // Use cached URL
        }
    }
    
    // Request new URL
    const response = await fetch(`/api/students/${studentId}/photos?size=${size}`);
    const { photoUrl } = await response.json();
    
    // Cache for 50 minutes (10 min before expiration)
    localStorage.setItem(`photo-${studentId}-${size}`, JSON.stringify({
        url: photoUrl,
        expires: new Date(Date.now() + 50 * 60 * 1000)
    }));
    
    return photoUrl;
}
```

#### **Q7: How do you handle photo updates?**

**Answer:**
- **Versioning**: S3 versioning keeps old versions
- **Replace Original**: Upload new photo with same key (creates new version)
- **Thumbnail Regeneration**: Regenerate thumbnails for new photo
- **Cache Invalidation**: Invalidate CDN cache if using CloudFront
- **Database Update**: Update photo metadata in database (upload date, size)

**Flow:**
1. User uploads new photo
2. Service uploads to same S3 key (versioning creates new version)
3. Old version preserved (can restore if needed)
4. Thumbnails regenerated
5. Pre-signed URLs point to new version

---

### **Part 5: Common Issues and Troubleshooting**

#### **Issue 1: "Access Denied" When Uploading Photos**

**Symptoms:**
- `403 Forbidden` error when uploading
- `Access Denied` in S3 logs

**Root Causes:**
1. IAM role doesn't have S3 permissions
2. Bucket policy denies access
3. Wrong bucket name in configuration
4. Region mismatch

**Solutions:**
```bash
# 1. Verify IAM role has S3 permissions
aws iam get-role-policy \
  --role-name OSPStudentServiceRole \
  --policy-name StudentPhotoS3AccessPolicy

# 2. Check bucket policy
aws s3api get-bucket-policy \
  --bucket osp-student-photos-us-east-1

# 3. Test S3 access with AWS CLI
aws s3 ls s3://osp-student-photos-us-east-1/

# 4. Verify bucket name in appsettings.json matches actual bucket
```

**Prevention:**
- Use IAM policy simulator to test permissions
- Test S3 access during deployment
- Monitor CloudWatch logs for access errors

---

#### **Issue 2: Pre-signed URLs Not Working**

**Symptoms:**
- URLs return 403 Forbidden
- URLs work in browser but not in application
- URLs expire immediately

**Root Causes:**
1. Clock skew (server time different from AWS time)
2. URL expired
3. Object doesn't exist
4. Wrong bucket/key in URL generation

**Solutions:**
```csharp
// Fix clock skew
var request = new GetPreSignedUrlRequest
{
    BucketName = _bucketName,
    Key = key,
    Verb = HttpVerb.GET,
    Expires = DateTime.UtcNow.Add(expiration) // Use UTC
};

// Verify object exists before generating URL
var exists = await PhotoExistsAsync(studentId, schoolId, size);
if (!exists)
{
    throw new FileNotFoundException("Photo not found");
}

// Log URL generation for debugging
_logger.LogInformation(
    "Generated pre-signed URL. Key: {Key}, Expires: {Expires}",
    key,
    DateTime.UtcNow.Add(expiration));
```

**Prevention:**
- Use NTP to sync server time
- Always use UTC for expiration times
- Verify object exists before URL generation
- Add logging for URL generation

---

#### **Issue 3: Slow Photo Uploads**

**Symptoms:**
- Uploads take too long
- Timeout errors
- Poor user experience

**Root Causes:**
1. Large file sizes
2. Synchronous thumbnail generation
3. Network latency
4. No compression

**Solutions:**
```csharp
// 1. Compress images before upload
image.Mutate(x => x.Resize(new ResizeOptions
{
    Size = new Size(maxWidth, maxHeight),
    Mode = ResizeMode.Max
}));

// 2. Use multipart upload for large files
if (fileSize > 100 * 1024 * 1024)
{
    // Use multipart upload
}

// 3. Generate thumbnails asynchronously
_ = Task.Run(async () =>
{
    await GenerateThumbnailsAsync(studentId, schoolId, stream);
});

// 4. Return immediately after original upload
return Ok(new { PhotoUrl = originalUrl });
```

**Prevention:**
- Set file size limits (5MB max)
- Resize images before upload
- Use async thumbnail generation
- Implement progress tracking

---

#### **Issue 4: High S3 Costs**

**Symptoms:**
- Unexpected S3 bills
- Storage costs higher than expected
- Data transfer costs high

**Root Causes:**
1. No lifecycle policies
2. Old photos not archived
3. No compression
4. High data transfer (no CDN)

**Solutions:**
```bash
# 1. Review current storage
aws s3 ls s3://osp-student-photos-us-east-1 --recursive --human-readable --summarize

# 2. Enable lifecycle policy
aws s3api put-bucket-lifecycle-configuration \
  --bucket osp-student-photos-us-east-1 \
  --lifecycle-configuration file://lifecycle-policy.json

# 3. Enable CloudFront CDN
aws cloudfront create-distribution \
  --origin-domain-name osp-student-photos-us-east-1.s3.amazonaws.com

# 4. Compress images before upload
```

**Prevention:**
- Set up lifecycle policies from day 1
- Monitor S3 costs in CloudWatch
- Use appropriate storage classes
- Enable CloudFront for public assets

---

#### **Issue 5: Thumbnails Not Generated**

**Symptoms:**
- Original photo uploaded but thumbnails missing
- 404 errors when accessing thumbnails
- Lambda function not triggered

**Root Causes:**
1. Lambda function not configured
2. S3 event notification not set up
3. Lambda function errors
4. Thumbnail generation code fails

**Solutions:**
```bash
# 1. Check S3 event configuration
aws s3api get-bucket-notification-configuration \
  --bucket osp-student-photos-us-east-1

# 2. Check Lambda function logs
aws logs tail /aws/lambda/GenerateThumbnails --follow

# 3. Test Lambda function manually
aws lambda invoke \
  --function-name GenerateThumbnails \
  --payload '{"key":"schools/123/students/456/original/photo.jpg"}' \
  response.json

# 4. Verify Lambda has S3 permissions
aws iam get-role-policy \
  --role-name GenerateThumbnailsRole \
  --policy-name S3AccessPolicy
```

**Prevention:**
- Test Lambda function during deployment
- Monitor Lambda CloudWatch logs
- Add error handling in Lambda
- Implement fallback to synchronous generation

---

#### **Issue 6: Photo Deletion Not Working**

**Symptoms:**
- Delete API succeeds but photo still exists
- Only some sizes deleted
- Versioning prevents deletion

**Root Causes:**
1. Versioning enabled (need to delete all versions)
2. Delete marker created instead of actual deletion
3. Permissions issue
4. Wrong key path

**Solutions:**
```csharp
// Delete all versions if versioning enabled
var listVersionsRequest = new ListVersionsRequest
{
    BucketName = _bucketName,
    Prefix = $"schools/{schoolId}/students/{studentId}/"
};

var versions = await _s3Client.ListVersionsAsync(listVersionsRequest);
foreach (var version in versions.Versions)
{
    await _s3Client.DeleteObjectAsync(
        _bucketName,
        version.Key,
        version.VersionId);
}
```

**Prevention:**
- Handle versioning in delete logic
- Verify deletion after operation
- Log deletion operations
- Test deletion during development

---

#### **Issue 7: CORS Errors in Browser**

**Symptoms:**
- CORS errors when accessing photos from frontend
- Pre-signed URLs work in Postman but not browser
- "No 'Access-Control-Allow-Origin' header" error

**Root Causes:**
1. CORS not configured on S3 bucket
2. Frontend domain not in allowed origins
3. Wrong CORS configuration

**Solutions:**
```bash
# Configure CORS on bucket
cat > cors-config.json <<EOF
{
  "CORSRules": [
    {
      "AllowedOrigins": [
        "https://student-portal.example.com",
        "https://admin-portal.example.com"
      ],
      "AllowedMethods": ["GET", "HEAD"],
      "AllowedHeaders": ["*"],
      "ExposeHeaders": ["ETag"],
      "MaxAgeSeconds": 3000
    }
  ]
}
EOF

aws s3api put-bucket-cors \
  --bucket osp-student-photos-us-east-1 \
  --cors-configuration file://cors-config.json
```

**Prevention:**
- Configure CORS during bucket setup
- Include all frontend domains
- Test CORS from browser console
- Monitor CORS errors in browser dev tools

---

### **Part 6: Monitoring and Observability**

#### **CloudWatch Metrics to Monitor**

```bash
# 1. Bucket size
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name BucketSizeBytes \
  --dimensions Name=BucketName,Value=osp-student-photos-us-east-1 \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Average

# 2. Number of objects
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name NumberOfObjects \
  --dimensions Name=BucketName,Value=osp-student-photos-us-east-1 \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Average

# 3. Put requests (uploads)
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name PutRequests \
  --dimensions Name=BucketName,Value=osp-student-photos-us-east-1 \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum

# 4. Get requests (downloads)
aws cloudwatch get-metric-statistics \
  --namespace AWS/S3 \
  --metric-name GetRequests \
  --dimensions Name=BucketName,Value=osp-student-photos-us-east-1 \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 3600 \
  --statistics Sum
```

#### **Set Up Alarms**

```bash
# Alarm for high upload errors
aws cloudwatch put-metric-alarm \
  --alarm-name s3-photo-upload-errors \
  --alarm-description "Alert when S3 upload errors increase" \
  --metric-name 4xxErrors \
  --namespace AWS/S3 \
  --statistic Sum \
  --period 300 \
  --threshold 10 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --dimensions Name=BucketName,Value=osp-student-photos-us-east-1

# Alarm for bucket size
aws cloudwatch put-metric-alarm \
  --alarm-name s3-photo-bucket-size \
  --alarm-description "Alert when bucket size exceeds 100GB" \
  --metric-name BucketSizeBytes \
  --namespace AWS/S3 \
  --statistic Average \
  --period 3600 \
  --threshold 107374182400 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1 \
  --dimensions Name=BucketName,Value=osp-student-photos-us-east-1
```

---

### **Summary: Complete Implementation Checklist**

**Cloud-Side Setup:**
- [ ] Create S3 bucket
- [ ] Enable versioning
- [ ] Enable encryption
- [ ] Configure bucket policy
- [ ] Block public access
- [ ] Create IAM role and policy
- [ ] Configure lifecycle policy
- [ ] Set up S3 event notifications (optional)
- [ ] Configure CORS (if needed)
- [ ] Set up CloudWatch alarms

**API-Side Implementation:**
- [ ] Install NuGet packages
- [ ] Configure appsettings.json
- [ ] Create service interface
- [ ] Implement photo service
- [ ] Create controller
- [ ] Register services
- [ ] Add error handling
- [ ] Add logging
- [ ] Add validation
- [ ] Implement thumbnail generation

**Testing:**
- [ ] Unit tests for service
- [ ] Integration tests for S3
- [ ] Test upload flow
- [ ] Test download flow
- [ ] Test deletion flow
- [ ] Test error scenarios
- [ ] Test security (unauthorized access)
- [ ] Test performance (large files)

**Monitoring:**
- [ ] Set up CloudWatch metrics
- [ ] Configure alarms
- [ ] Enable S3 access logging
- [ ] Set up application logging
- [ ] Create dashboards

---

### **Scenario 2: School Branding Assets (Logos, Banners)**

**Business Requirement:**
- Schools upload logos and banners for customization
- Assets displayed on student and admin portals
- Need fast delivery (CDN integration)

**S3 Implementation:**

**Bucket Structure:**
```
osp-school-assets/
├── schools/
│   ├── school-123/
│   │   ├── logo.png
│   │   ├── banner.jpg
│   │   ├── favicon.ico
│   │   └── theme/
│   │       └── colors.json
```

**CloudFront CDN Integration:**

1. **Create CloudFront Distribution**
```bash
aws cloudfront create-distribution \
  --origin-domain-name osp-school-assets-us-east-1.s3.amazonaws.com \
  --default-root-object index.html
```

2. **Benefits:**
- Faster delivery: Content cached at edge locations globally
- Reduced S3 costs: Lower data transfer costs
- Better performance: Reduced latency for users worldwide

**API Implementation:**

```csharp
// Controllers/SchoolBrandingController.cs
[ApiController]
[Route("api/schools/{schoolId}/branding")]
public class SchoolBrandingController : ControllerBase
{
    private readonly ISchoolAssetService _assetService;

    [HttpPost("logo")]
    public async Task<IActionResult> UploadLogo(
        string schoolId, 
        IFormFile logoFile)
    {
        if (logoFile == null || logoFile.Length == 0)
            return BadRequest("No file uploaded");

        // Validate file type
        if (!logoFile.ContentType.StartsWith("image/"))
            return BadRequest("Invalid file type");

        using var stream = logoFile.OpenReadStream();
        var url = await _assetService.UploadLogoAsync(schoolId, stream);

        return Ok(new { LogoUrl = url });
    }

    [HttpGet("logo")]
    public async Task<IActionResult> GetLogo(string schoolId)
    {
        var url = await _assetService.GetLogoUrlAsync(schoolId);
        return Ok(new { LogoUrl = url });
    }
}
```

---

### **Scenario 3: Document Storage (Transcripts, Certificates)**

**Business Requirement:**
- Students upload transcripts, certificates, ID documents
- School admins upload official documents
- Need versioning and audit trails
- Long-term storage (archive after graduation)

**S3 Implementation:**

**Bucket Structure:**
```
osp-documents/
├── schools/
│   ├── school-123/
│   │   ├── students/
│   │   │   ├── student-456/
│   │   │   │   ├── transcripts/
│   │   │   │   │   └── transcript-2024.pdf
│   │   │   │   ├── certificates/
│   │   │   │   │   └── certificate-abc123.pdf
│   │   │   │   └── id-documents/
│   │   │   │       └── id-proof.pdf
```

**Lifecycle Policy for Archival:**

```json
{
  "Rules": [
    {
      "Id": "ArchiveOldDocuments",
      "Status": "Enabled",
      "Prefix": "schools/",
      "Transitions": [
        {
          "Days": 365,
          "StorageClass": "GLACIER"
        },
        {
          "Days": 1095,
          "StorageClass": "DEEP_ARCHIVE"
        }
      ]
    }
  ]
}
```

**Implementation:**

```csharp
// Services/IDocumentService.cs
public interface IDocumentService
{
    Task<string> UploadDocumentAsync(
        string studentId, 
        string schoolId, 
        string documentType, 
        Stream documentStream,
        string fileName);
    
    Task<DocumentInfo> GetDocumentInfoAsync(string documentId);
    Task<Stream> DownloadDocumentAsync(string documentId);
}

public class DocumentService : IDocumentService
{
    private readonly IAmazonS3 _s3Client;
    private readonly string _bucketName;
    private readonly IDocumentRepository _repository;

    public async Task<string> UploadDocumentAsync(
        string studentId,
        string schoolId,
        string documentType,
        Stream documentStream,
        string fileName)
    {
        var documentId = Guid.NewGuid().ToString();
        var key = $"schools/{schoolId}/students/{studentId}/{documentType}/{documentId}-{fileName}";

        var request = new PutObjectRequest
        {
            BucketName = _bucketName,
            Key = key,
            InputStream = documentStream,
            ContentType = "application/pdf",
            ServerSideEncryptionMethod = ServerSideEncryptionMethod.AES256,
            Metadata = new Dictionary<string, string>
            {
                ["student-id"] = studentId,
                ["school-id"] = schoolId,
                ["document-type"] = documentType,
                ["upload-date"] = DateTime.UtcNow.ToString("O")
            }
        };

        await _s3Client.PutObjectAsync(request);

        // Store document metadata in database
        await _repository.SaveDocumentInfoAsync(new DocumentInfo
        {
            DocumentId = documentId,
            StudentId = studentId,
            SchoolId = schoolId,
            DocumentType = documentType,
            S3Key = key,
            FileName = fileName,
            UploadedAt = DateTime.UtcNow
        });

        return documentId;
    }
}
```

**Benefits:**
- Versioning: Track document changes
- Lifecycle policies: Automatically archive old documents
- Audit trail: Metadata stored for compliance
- Cost optimization: Move to Glacier after 1 year

---

### **Scenario 4: Generated Reports and Invoices (PDF Storage)**

**Business Requirement:**
- Generate PDF reports (fee reports, enrollment reports)
- Generate payment invoices and receipts
- Store for long-term access
- Download on-demand

**S3 Implementation:**

**Bucket Structure:**
```
osp-reports/
├── schools/
│   ├── school-123/
│   │   ├── reports/
│   │   │   ├── fee-reports/
│   │   │   │   └── 2024-01-fee-report.pdf
│   │   │   ├── enrollment-reports/
│   │   │   │   └── 2024-01-enrollment.pdf
│   │   │   └── payment-reports/
│   │   │       └── 2024-01-payment.pdf
│   │   └── invoices/
│   │       ├── students/
│   │       │   ├── student-456/
│   │       │   │   └── invoice-789.pdf
│   │       │   └── receipts/
│   │       │       └── receipt-789.pdf
```

**Implementation:**

```csharp
// Services/IReportService.cs
public interface IReportService
{
    Task<string> GenerateAndStoreFeeReportAsync(string schoolId, DateTime reportDate);
    Task<string> GenerateAndStoreInvoiceAsync(string studentId, string paymentId);
    Task<string> GetReportUrlAsync(string reportId);
}

public class ReportService : IReportService
{
    private readonly IAmazonS3 _s3Client;
    private readonly string _bucketName;
    private readonly IPdfGenerator _pdfGenerator;

    public async Task<string> GenerateAndStoreFeeReportAsync(
        string schoolId, 
        DateTime reportDate)
    {
        // 1. Generate PDF report
        var reportData = await _reportRepository.GetFeeReportDataAsync(schoolId, reportDate);
        var pdfBytes = await _pdfGenerator.GenerateFeeReportPdfAsync(reportData);

        // 2. Upload to S3
        var key = $"schools/{schoolId}/reports/fee-reports/{reportDate:yyyy-MM}-fee-report.pdf";
        
        var request = new PutObjectRequest
        {
            BucketName = _bucketName,
            Key = key,
            InputStream = new MemoryStream(pdfBytes),
            ContentType = "application/pdf",
            ServerSideEncryptionMethod = ServerSideEncryptionMethod.AES256
        };

        await _s3Client.PutObjectAsync(request);

        // 3. Generate pre-signed URL (valid for 7 days)
        var url = await GeneratePreSignedUrlAsync(key, TimeSpan.FromDays(7));

        return url;
    }
}
```

**Lifecycle Policy:**
```json
{
  "Rules": [
    {
      "Id": "ArchiveOldReports",
      "Status": "Enabled",
      "Prefix": "schools/",
      "Transitions": [
        {
          "Days": 90,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 365,
          "StorageClass": "GLACIER"
        }
      ]
    }
  ]
}
```

**Benefits:**
- On-demand generation: Generate reports when needed
- Long-term storage: Keep reports for years
- Cost-effective: Move to cheaper storage classes automatically
- Secure access: Pre-signed URLs for private reports

---

### **Scenario 5: Activity Images and Media**

**Business Requirement:**
- Upload activity images (sports, arts, clubs)
- Store activity-related media files
- Fast delivery for student portal

**S3 Implementation:**

**Bucket Structure:**
```
osp-activity-media/
├── schools/
│   ├── school-123/
│   │   ├── activities/
│   │   │   ├── activity-789/
│   │   │   │   ├── images/
│   │   │   │   │   ├── main-image.jpg
│   │   │   │   │   └── gallery/
│   │   │   │   │       ├── image1.jpg
│   │   │   │   │       └── image2.jpg
│   │   │   │   └── videos/
│   │   │   │       └── intro-video.mp4
```

**CloudFront Integration:**
- Use CloudFront CDN for fast image delivery
- Reduce latency for students viewing activities
- Lower S3 data transfer costs

---

### **Scenario 6: Backup and Disaster Recovery**

**Business Requirement:**
- Backup critical data (databases, configurations)
- Cross-region replication for disaster recovery
- Long-term retention

**S3 Implementation:**

**Cross-Region Replication:**
```bash
# Enable replication from us-east-1 to us-west-2
aws s3api put-bucket-replication \
  --bucket osp-backups-us-east-1 \
  --replication-configuration file://replication-config.json
```

**Replication Configuration:**
```json
{
  "Role": "arn:aws:iam::ACCOUNT_ID:role/replication-role",
  "Rules": [
    {
      "Id": "ReplicateAll",
      "Status": "Enabled",
      "Prefix": "",
      "Destination": {
        "Bucket": "arn:aws:s3:::osp-backups-us-west-2",
        "StorageClass": "STANDARD"
      }
    }
  ]
}
```

---

## **Part 3: S3 Best Practices in OSP**

### **1. Security Best Practices**

**Encryption:**
- Enable server-side encryption (SSE-S3 or SSE-KMS)
- Use bucket policies to restrict access
- Use IAM roles for service access
- Generate pre-signed URLs for temporary access

**Access Control:**
- Principle of least privilege
- Use bucket policies for bucket-level rules
- Use IAM policies for user/service access
- Enable MFA Delete for critical buckets

### **2. Cost Optimization**

**Storage Classes:**
- Use Standard for frequently accessed data
- Use Standard-IA for infrequently accessed data
- Use Glacier for archival data
- Use Intelligent-Tiering for unknown access patterns

**Lifecycle Policies:**
- Automatically transition to cheaper storage classes
- Delete old/unnecessary objects
- Reduce storage costs by 40-68%

**Compression:**
- Compress files before uploading (especially for reports)
- Use appropriate file formats (JPEG for photos, PDF for documents)

### **3. Performance Optimization**

**CloudFront CDN:**
- Use CloudFront for public assets (logos, images)
- Reduce latency for global users
- Lower S3 data transfer costs

**Multipart Upload:**
- For large files (>100MB), use multipart upload
- Improves upload reliability and speed

**Request Optimization:**
- Batch operations when possible
- Use appropriate request patterns
- Cache frequently accessed URLs

### **4. Monitoring and Observability**

**CloudWatch Metrics:**
- Monitor bucket size
- Track request counts
- Monitor data transfer
- Set up alarms for unusual activity

**S3 Access Logging:**
- Enable access logging for audit trails
- Track who accessed what objects
- Useful for compliance and security

---

## **Part 4: Common Interview Questions**

### **Q1: Why use S3 instead of database BLOB storage?**

**Answer:**
- **Scalability**: S3 scales infinitely; databases have limits
- **Cost**: S3 is cheaper for large files (pay per GB vs database storage)
- **Performance**: S3 optimized for file storage; databases optimized for structured data
- **Features**: S3 provides versioning, lifecycle policies, CDN integration
- **Separation of Concerns**: Keep files separate from transactional data

### **Q2: How do you ensure security for student photos?**

**Answer:**
- **Private Buckets**: Buckets are private by default
- **IAM Policies**: Services access S3 via IAM roles (least privilege)
- **Pre-signed URLs**: Generate temporary URLs (1-hour expiry) for viewing
- **Encryption**: Enable server-side encryption (SSE-S3 or SSE-KMS)
- **Bucket Policies**: Restrict access to specific IAM roles
- **Access Logging**: Track all access for audit purposes

### **Q3: How do you handle large file uploads?**

**Answer:**
- **Multipart Upload**: For files >100MB, use multipart upload API
- **Progress Tracking**: Show upload progress to users
- **Resumable Uploads**: Handle network interruptions
- **Validation**: Validate file size, type before upload
- **Async Processing**: Upload to S3, then process asynchronously

### **Q4: How do you optimize costs?**

**Answer:**
- **Lifecycle Policies**: Automatically move old data to cheaper storage classes
  - Reports: Standard → Standard-IA (90 days) → Glacier (1 year)
- **Storage Classes**: Use appropriate class for access pattern
- **Compression**: Compress files before uploading
- **CloudFront**: Use CDN to reduce data transfer costs
- **Delete Old Data**: Automatically delete unnecessary files

### **Q5: How do you handle versioning?**

**Answer:**
- **Enable Versioning**: Keep multiple versions of objects
- **Protect Against Deletion**: Can restore previous versions
- **Audit Trail**: Track when objects changed
- **Lifecycle Policies**: Can manage old versions (delete after X days)
- **Use Cases**: Student photo updates, document revisions, report regeneration

---

## **Summary**

**AWS S3 in OSP Project:**

1. **Student Profile Photos** → Private storage with pre-signed URLs
2. **School Branding** → Public assets with CloudFront CDN
3. **Documents** → Versioned storage with lifecycle policies
4. **Reports/Invoices** → On-demand generation with archival
5. **Activity Media** → Fast delivery with CDN
6. **Backups** → Cross-region replication for DR

**Key Benefits:**
- **Scalability**: Handle unlimited files
- **Durability**: 11 9's durability
- **Cost-Effective**: Pay only for what you use
- **Security**: Encryption, access control, audit trails
- **Performance**: CDN integration for fast delivery
- **Automation**: Lifecycle policies, versioning, replication

**Technical Implementation:**
- AWS SDK for .NET Core
- Pre-signed URLs for secure access
- Lifecycle policies for cost optimization
- CloudFront CDN for performance
- IAM roles for service access
- Encryption at rest and in transit

---

## **How to Present in Interview**

### **Opening (10-15 seconds):**
"I implemented AWS S3 for file storage in the OSP project, handling student photos, school branding, documents, and generated reports. S3's scalability and cost-effective storage classes, combined with CloudFront CDN, enabled us to serve files globally while maintaining security through encryption and pre-signed URLs."

### **Key Points to Cover:**
1. **Use Cases**: Student photos, documents, reports, branding
2. **Security**: Encryption, IAM policies, pre-signed URLs
3. **Cost Optimization**: Lifecycle policies, storage classes
4. **Performance**: CloudFront CDN integration
5. **Scalability**: Handled thousands of files across multiple schools

### **Technical Depth:**
- Explain storage classes and when to use each
- Describe lifecycle policies and cost savings
- Discuss security measures (encryption, access control)
- Explain pre-signed URLs and their use cases
- Mention CloudFront CDN for performance

---

**Remember**: Connect technical implementation to business value - cost savings, security, scalability, and user experience.

