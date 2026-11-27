provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile # null = use the default AWS CLI credential chain

  # Tags automatically added to ALL resources
  default_tags {
    tags = {
      Owner       = var.owner
      Team        = var.team
      Environment = var.environment
      Project     = var.project
      ManagedBy  = "Terraform"
    }
  }
}
