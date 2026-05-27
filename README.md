# tf-molecule-iam-service-role-aws

Terraform molecule that composes IAM atoms into a complete service role with managed policy, role-policy attachment, and optional EC2 instance profile.

## Atoms Composed

| Atom | Purpose |
|------|---------|
| `tf-atom-iam-role-aws` | Creates the IAM role with trust policy |
| `tf-atom-iam-policy-aws` | Creates the managed permissions policy |
| `tf-atom-iam-role-policy-attachment-aws` | Attaches the policy to the role |
| `tf-atom-iam-instance-profile-aws` | (Optional) Creates EC2 instance profile |

## Usage

```hcl
module "lambda_role" {
  source = "git::https://github.com/PlatformStackPulse/tf-molecule-iam-service-role-aws.git?ref=v1.0.0"

  namespace   = "psp"
  environment = "prod"
  name        = "lambda-processor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}
```

## With Instance Profile (EC2)

```hcl
module "ec2_role" {
  source = "git::https://github.com/PlatformStackPulse/tf-molecule-iam-service-role-aws.git?ref=v1.0.0"

  namespace   = "psp"
  environment = "prod"
  name        = "web-server"

  create_instance_profile = true

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["s3:GetObject"]
      Resource = "arn:aws:s3:::my-bucket/*"
    }]
  })
}
```
