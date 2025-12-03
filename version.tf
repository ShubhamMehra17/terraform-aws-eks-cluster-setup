terraform {
  required_version = ">= 1.2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


   backend "s3" {
     bucket = "vyomentum-dp-prod--terraform-bucket"
     key    = "eks-prod/terraform.tfstate"
     region = "ap-south-1"
     dynamodb_table = "terraform-locks"
   }
}
