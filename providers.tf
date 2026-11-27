provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile # null = use the default AWS CLI credential chain

  # Tags automatically added to ALL resources
  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
