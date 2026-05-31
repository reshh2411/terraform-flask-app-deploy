terraform {
  backend "s3" {
    bucket = "reshma-terraform-state-s3" #unique name for the bucket
    key    = "reshma-terraform-state/terraform.tfstate" #path to the state file
    region = "eu-north-1" #region where the bucket is located
  }
}
