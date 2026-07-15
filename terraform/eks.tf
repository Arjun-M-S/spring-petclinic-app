terraform{
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.92" 
        }
    }

    required_version = ">= 1.5.0"
}

module "eks" {
  source                 = "terraform-aws-modules/eks/aws"
  version                = "21.0.1"
  name                   = "petclinic-eks-cluster"
  kubernetes_version     = "1.30"
  subnet_ids             = module.vpc.private_subnets
  vpc_id                 = module.vpc.vpc_id
  endpoint_public_access = true
  
  eks_managed_node_groups = {
    petclinic_nodes = {
        min_size = 1
        max_size = 2
        desired_size = 1
        instance_types = ["t3.medium"]
    }
  }
}