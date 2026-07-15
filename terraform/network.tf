terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.92" 
    }

  }
  required_version = ">= 1.5.0"
}

provider "aws" {
  region = "ap-south-2"
}

module "vpc"{
    source  = "terraform-aws-modules/vpc/aws"
    version = "5.1.2"
    name = "petclinic-vpc"
    cidr = "10.0.0.0/16"
    azs = ["ap-south-2a", "ap-south-2b", "ap-south-2c"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24"] 
    public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]
    enable_nat_gateway = true
    single_nat_gateway = true
    public_subnet_tags = {
        "kubernetes.io/role/elb" = 1
    }
    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1
    }
}