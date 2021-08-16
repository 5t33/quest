module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.vpc_name}-${var.environment}"
  cidr = "10.0.0.0/23"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.0.0/25", "10.0.0.128/25"]
  public_subnets  = ["10.0.1.0/25", "10.0.1.128/25"]

  enable_nat_gateway = true
  create_igw = true

  tags = {
    Terraform = "true"
    Environment = var.environment
  }
}