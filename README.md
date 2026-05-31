# Terraform Provisioners Project

A simple Terraform project that provisions AWS infrastructure and includes a small Flask application example.

## Repository structure

- `main.tf` - AWS infrastructure resources including VPC, subnet, internet gateway, route table, security group, and EC2 key pair.
- `backend.tf` - Terraform S3 backend configuration for remote state storage.
- `app.py` - Minimal Flask app used as an example application.

## Prerequisites

- Terraform installed
- AWS CLI installed and configured with credentials that can create S3 buckets and AWS resources
- An existing S3 bucket for Terraform remote state

## Backend configuration

This project uses an S3 backend for Terraform state:

```hcl
terraform {
  backend "s3" {
    bucket = "reshma-terraform-state-s3"
    key    = "reshma-terraform-state/terraform.tfstate"
    region = "eu-north-1"
  }
}
```

The S3 bucket must exist before running `terraform init`.

### Create the backend bucket

Using AWS CLI:

```bash
aws s3api create-bucket --bucket reshma-terraform-state-s3 --region eu-north-1 --create-bucket-configuration LocationConstraint=eu-north-1
```

If the bucket is already created, you can continue with Terraform initialization.

## Usage

1. Initialize Terraform:

```bash
terraform init
```

2. Review the Terraform plan:

```bash
terraform plan
```

3. Apply the configuration:

```bash
terraform apply
```

4. Confirm when prompted to create the resources.

## Notes

- If the S3 backend is not available yet, you can temporarily remove or comment out the `terraform { backend "s3" { ... } }` block in `backend.tf` and use local state for initial testing.
- `app.py` is a simple Flask example and is not currently deployed by Terraform.
- Adjust AWS region and resource names as needed for your environment.
