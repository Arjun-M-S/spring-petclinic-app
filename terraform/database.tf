terraform{
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.92" 
        }
    }

    required_version = ">= 1.5.0"
}


module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.0.0"
  
  name        = "petclinic-sg"
  description = "Security group for petclinic application"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      description = "Allow MySQL traffic from within the VPC"
      from_port   = 3306
      protocol    = "tcp"
      to_port     = 3306
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]
}

resource "aws_db_subnet_group" "default" {
    name = "petclinic-db-subnet-group"
    subnet_ids = module.vpc.private_subnets
}

resource "random_password" "db_password" {
  length  = 16
  special = false 
}

resource "aws_secretsmanager_secret" "db_password" {
  name = "petclinic-db-password"
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}


resource "aws_db_instance" "default" {
    allocated_storage    = 20
    engine               = "mysql"
    engine_version       = "8.0"
    instance_class       = "db.t3.micro"
    db_name              =  "petclinicdb"
    username             = "admin"
    password             = aws_secretsmanager_secret_version.db_password.secret_string
    parameter_group_name = "default.mysql8.0"
    skip_final_snapshot  = true
    publicly_accessible  = false
    vpc_security_group_ids = [module.security_group.security_group_id]
    db_subnet_group_name   = aws_db_subnet_group.default.name
}   

