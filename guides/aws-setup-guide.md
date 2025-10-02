# AWS Setup Guide for AI Practitioner Environment

## Prerequisites

- Active AWS Account
- AWS CLI installed in container (provided by this environment)
- Basic understanding of IAM policies and roles

## Table of Contents

1. [AWS Account Setup](#aws-account-setup)
2. [IAM User and Credentials Configuration](#iam-user-and-credentials-configuration)
3. [IAM Policy Configuration](#iam-policy-configuration)
4. [AWS CLI Configuration](#aws-cli-configuration)
5. [Billing and Cost Management](#billing-and-cost-management)
6. [Service-Specific Setup](#service-specific-setup)
7. [Security Best Practices](#security-best-practices)
8. [Verification Steps](#verification-steps)

---

## AWS Account Setup

### 1. Create AWS Account

If you don't have an AWS account:

1. Go to [https://aws.amazon.com](https://aws.amazon.com)
2. Click "Create an AWS Account"
3. Follow the registration process
4. Provide payment method (required even for free tier)
5. Verify your identity via phone
6. Choose Support Plan (Basic/Free is sufficient for learning)

### 2. Enable MFA (Multi-Factor Authentication)

**Highly Recommended for Security**

1. Sign in to AWS Console
2. Click your account name → Security Credentials
3. Under "Multi-factor authentication (MFA)", click "Assign MFA device"
4. Choose virtual MFA device
5. Use Google Authenticator, Authy, or similar app
6. Scan QR code and enter two consecutive MFA codes

---

## IAM User and Credentials Configuration

### Option 1: Using Root Account Credentials (NOT RECOMMENDED)

⚠️ **Never use root account credentials for daily operations!**

### Option 2: Create IAM User (RECOMMENDED)

#### Step 1: Create IAM User

```bash
aws iam create-user --user-name ai-practitioner-user
```

Or via AWS Console:

1. Go to IAM Dashboard → Users → Add User
2. User name: `ai-practitioner-user`
3. Access type: Select "Programmatic access"
4. Click "Next: Permissions"

#### Step 2: Attach Policies

You can use the provided `iam-policy-template.json` or attach AWS managed policies.

**Using Custom Policy (Recommended):**

```bash
aws iam create-policy \
  --policy-name AIPractitionerPolicy \
  --policy-document file://iam-policy-template.json
```

Then attach to user:

```bash
aws iam attach-user-policy \
  --user-name ai-practitioner-user \
  --policy-arn arn:aws:iam::YOUR_ACCOUNT_ID:policy/AIPractitionerPolicy
```

**Using AWS Managed Policies (Alternative):**

```bash
aws iam attach-user-policy \
  --user-name ai-practitioner-user \
  --policy-arn arn:aws:iam::aws:policy/AmazonBedrockFullAccess

aws iam attach-user-policy \
  --user-name ai-practitioner-user \
  --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
```

#### Step 3: Create Access Keys

```bash
aws iam create-access-key --user-name ai-practitioner-user
```

**Save the output!** You'll need:
- `AccessKeyId`
- `SecretAccessKey`

Or via Console:
1. IAM → Users → ai-practitioner-user → Security Credentials
2. Create access key
3. Download .csv file with credentials

---

## IAM Policy Configuration

### Understanding the Provided Policy Template

The `iam-policy-template.json` includes permissions for:

1. **Amazon Bedrock** - Full access to foundation models
2. **Amazon SageMaker** - ML model training and deployment
3. **AI Services** - Comprehend, Rekognition, Textract, Polly, Transcribe
4. **Governance** - CloudTrail, Config, KMS for security/compliance
5. **Monitoring** - CloudWatch for logging and metrics
6. **Cost Management** - Cost Explorer and Budgets
7. **IAM/STS** - Required for role assumption and identity checks

### Policy Customization

To restrict access to specific regions:

```json
{
    "Condition": {
        "StringEquals": {
            "aws:RequestedRegion": ["us-east-1", "us-west-2"]
        }
    }
}
```

To add cost limit conditions:

```json
{
    "Condition": {
        "NumericLessThan": {
            "aws:RequestTag/CostLimit": "100"
        }
    }
}
```

---

## AWS CLI Configuration

### Method 1: Interactive Configuration

Inside the container:

```bash
aws configure
```

Enter:
- **AWS Access Key ID**: Your access key
- **AWS Secret Access Key**: Your secret key
- **Default region name**: `us-east-1`
- **Default output format**: `json`

### Method 2: Manual Configuration

Create `~/.aws/credentials`:

```ini
[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
```

Create `~/.aws/config`:

```ini
[default]
region = us-east-1
output = json
```

### Method 3: Environment Variables

In `docker-compose.yml`:

```yaml
environment:
  - AWS_ACCESS_KEY_ID=your_access_key
  - AWS_SECRET_ACCESS_KEY=your_secret_key
  - AWS_DEFAULT_REGION=us-east-1
```

### Verify Configuration

```bash
aws sts get-caller-identity
```

Expected output:
```json
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/ai-practitioner-user"
}
```

---

## Billing and Cost Management

### 1. Enable Billing Alerts

#### Prerequisites

1. Sign in as root user
2. Go to Billing Dashboard → Billing Preferences
3. Check "Receive Billing Alerts"
4. Save preferences

#### Create SNS Topic for Alerts

```bash
aws sns create-topic --name billing-alerts --region us-east-1
```

Subscribe to topic:

```bash
aws sns subscribe \
  --topic-arn arn:aws:sns:us-east-1:YOUR_ACCOUNT_ID:billing-alerts \
  --protocol email \
  --notification-endpoint your-email@example.com \
  --region us-east-1
```

Confirm subscription via email!

#### Create Billing Alarm

Update the script in `scripts/configure-billing-alerts.sh` with your account ID:

```bash
#!/bin/bash

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

aws cloudwatch put-metric-alarm \
    --alarm-name "AI-Practice-Billing-Alert" \
    --alarm-description "Alert when estimated charges exceed $10" \
    --metric-name EstimatedCharges \
    --namespace AWS/Billing \
    --statistic Maximum \
    --period 86400 \
    --threshold 10 \
    --comparison-operator GreaterThanThreshold \
    --dimensions Name=Currency,Value=USD \
    --evaluation-periods 1 \
    --alarm-actions arn:aws:sns:us-east-1:${ACCOUNT_ID}:billing-alerts \
    --region us-east-1

echo "✅ Billing alert configured for account ${ACCOUNT_ID}"
```

Run the script:

```bash
/scripts/configure-billing-alerts.sh
```

### 2. Set Up AWS Budgets

```bash
aws budgets create-budget \
  --account-id YOUR_ACCOUNT_ID \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

Example `budget.json`:

```json
{
  "BudgetName": "AI-Practice-Monthly-Budget",
  "BudgetLimit": {
    "Amount": "50",
    "Unit": "USD"
  },
  "TimeUnit": "MONTHLY",
  "BudgetType": "COST"
}
```

### 3. Monitor Costs

```bash
aws ce get-cost-and-usage \
  --time-period Start=2025-10-01,End=2025-10-31 \
  --granularity MONTHLY \
  --metrics "BlendedCost" \
  --region us-east-1
```

---

## Service-Specific Setup

### Amazon Bedrock

#### 1. Enable Model Access

Bedrock requires explicit model access request:

1. Go to AWS Console → Bedrock
2. Click "Model access" in left sidebar
3. Click "Manage model access"
4. Select models you want to use:
   - **Claude** (Anthropic)
   - **Titan** (Amazon)
   - **Llama** (Meta)
   - **Stable Diffusion** (Stability AI)
5. Submit access request

⚠️ **Note**: Some models require use case justification.

#### 2. Verify Model Access

```bash
aws bedrock list-foundation-models --region us-east-1
```

#### 3. Test Model Invocation

```bash
aws bedrock-runtime invoke-model \
  --model-id anthropic.claude-v2 \
  --body '{"prompt": "\n\nHuman: Hello\n\nAssistant:", "max_tokens_to_sample": 100}' \
  --region us-east-1 \
  output.json
```

### Amazon SageMaker

#### 1. Create SageMaker Execution Role

```bash
aws iam create-role \
  --role-name SageMakerExecutionRole \
  --assume-role-policy-document file://trust-policy.json
```

`trust-policy.json`:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sagemaker.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

Attach policy:

```bash
aws iam attach-role-policy \
  --role-name SageMakerExecutionRole \
  --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
```

#### 2. Create S3 Bucket for SageMaker

```bash
aws s3 mb s3://ai-practitioner-sagemaker-bucket --region us-east-1
```

### AI Services Setup

Most AI services work out-of-the-box with proper IAM permissions:

- **Amazon Comprehend**: No additional setup
- **Amazon Rekognition**: No additional setup
- **Amazon Textract**: No additional setup
- **Amazon Polly**: No additional setup
- **Amazon Transcribe**: May require S3 bucket for large files

---

## Security Best Practices

### 1. Use IAM Roles Instead of Keys (When Possible)

For EC2 instances or Lambda functions, use IAM roles instead of access keys.

### 2. Rotate Access Keys Regularly

```bash
aws iam create-access-key --user-name ai-practitioner-user

aws iam delete-access-key \
  --user-name ai-practitioner-user \
  --access-key-id OLD_ACCESS_KEY_ID
```

### 3. Enable CloudTrail

```bash
aws cloudtrail create-trail \
  --name ai-practitioner-trail \
  --s3-bucket-name ai-practitioner-cloudtrail-bucket \
  --is-multi-region-trail

aws cloudtrail start-logging --name ai-practitioner-trail
```

### 4. Use Least Privilege Principle

Only grant permissions that are absolutely necessary.

### 5. Monitor with AWS Config

Enable AWS Config to track resource changes:

```bash
aws configservice put-configuration-recorder \
  --configuration-recorder file://config-recorder.json

aws configservice put-delivery-channel \
  --delivery-channel file://delivery-channel.json

aws configservice start-configuration-recorder \
  --configuration-recorder-name default
```

---

## Verification Steps

### Complete Setup Checklist

Run these commands to verify your setup:

```bash
echo "1. Testing AWS CLI connection..."
aws sts get-caller-identity

echo -e "\n2. Checking Bedrock access..."
aws bedrock list-foundation-models --region us-east-1 --query 'modelSummaries[0].modelId' --output text

echo -e "\n3. Checking SageMaker access..."
aws sagemaker list-domains --region us-east-1

echo -e "\n4. Checking Comprehend access..."
aws comprehend list-entities-detection-jobs --region us-east-1

echo -e "\n5. Checking Rekognition access..."
aws rekognition list-collections --region us-east-1

echo -e "\n6. Checking CloudWatch alarms..."
aws cloudwatch describe-alarms --region us-east-1

echo -e "\n7. Checking billing alerts..."
aws cloudwatch describe-alarms --alarm-names "AI-Practice-Billing-Alert" --region us-east-1

echo -e "\n✅ All checks complete!"
```

### Test Script

Save as `scripts/verify-aws-setup.sh`:

```bash
#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

function check_command() {
    if $1 &>/dev/null; then
        echo -e "${GREEN}✓${NC} $2"
    else
        echo -e "${RED}✗${NC} $2"
    fi
}

echo "AWS Setup Verification"
echo "======================"

check_command "aws sts get-caller-identity" "AWS CLI authentication"
check_command "aws bedrock list-foundation-models --region us-east-1" "Bedrock access"
check_command "aws sagemaker list-domains --region us-east-1" "SageMaker access"
check_command "aws comprehend list-entities-detection-jobs --region us-east-1" "Comprehend access"
check_command "aws rekognition list-collections --region us-east-1" "Rekognition access"

echo -e "\nSetup verification complete!"
```

---

## Troubleshooting

### Access Denied Errors

**Problem**: `An error occurred (AccessDenied) when calling the ListFoundationModels operation`

**Solution**:
1. Check IAM policy is attached to user
2. Verify Bedrock model access is enabled in console
3. Confirm correct region (us-east-1)

### Credential Errors

**Problem**: `Unable to locate credentials`

**Solution**:
1. Run `aws configure`
2. Verify `~/.aws/credentials` exists
3. Check environment variables

### Region Issues

**Problem**: Service not available in region

**Solution**:
- Always use `us-east-1` for maximum AI service availability
- Some services have limited regional availability

### Billing Alerts Not Working

**Problem**: Not receiving billing alerts

**Solution**:
1. Confirm email subscription to SNS topic
2. Verify CloudWatch alarm is active
3. Check billing preferences are enabled (root account only)

---

## Additional Resources

- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS Bedrock User Guide](https://docs.aws.amazon.com/bedrock/latest/userguide/)
- [AWS CLI Command Reference](https://awscli.amazonaws.com/v2/documentation/api/latest/index.html)
- [AWS Cost Management](https://docs.aws.amazon.com/cost-management/)
- [AWS Security Best Practices](https://aws.amazon.com/architecture/security-identity-compliance/)

---

**Last Updated**: October 2025  
**Version**: 1.0
