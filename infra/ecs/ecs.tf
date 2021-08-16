
data "aws_caller_identity" "this" {}

data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnet_ids" "subnets" {
  vpc_id = local.vpc_id
  filter {
    name = "tag:Name"
    values = var.subnet_names
  }
}

data "aws_security_groups" "sgs" {
  filter {
    name = "group-name"
    values = var.security_group_names
  }
}

locals { 
  account_id = data.aws_caller_identity.this.account_id
  vpc_id = data.aws_vpc.vpc.id
  security_groups = data.aws_security_groups.sgs.ids
  subnets = data.aws_subnet_ids.subnets.ids
  short_region = var.aws_short_region[var.aws_region]
}

locals {
  container_image = "${local.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.image_repo}:${var.image_tag}"
  subnet_arns = [for subnet in local.subnets: "arn:aws:ec2:${var.aws_region}:${local.account_id}:subnet/${subnet}"]
}

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
  capacity_providers = ["FARGATE_SPOT"]
}

module "ecs" {
    source      = "git@github.com:5t33/ecs-service-module?ref=v0.2.2alpha"
    depends_on = [aws_ecs_cluster.cluster]
    environment = var.environment
    launch_type = var.launch_type
    aws_region  = var.aws_region
    task_execution_role_arn = aws_iam_role.task_execution_role.arn
    name_preffix = var.project_name
    ecs_cluster_name = var.cluster_name
    vpc_id = local.vpc_id
    lb_name = var.lb_name
    path_patterns = var.path_patterns 
    container_name = var.project_name
    container_port = var.container_port
    container_image = local.container_image
    tg_health_check_path = var.health_check_path
    task_definition_family = var.project_name
    create_load_balancing = true
    listener_port = var.listener_port
    create_autoscaling = false
    task_cpu = var.task_cpu
    task_memory = var.task_memory
    tags = {
      Environment = var.environment
      Terraform = "true"
    }
    network_configuration = {
      subnets = local.subnets
      security_groups = local.security_groups
      assign_public_ip = false
    }
}
