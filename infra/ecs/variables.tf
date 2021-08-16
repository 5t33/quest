
# AWS
variable "aws_profile" {
  type = string
}

variable "aws_region" {
  type = string
}

# Misc 
variable "aws_short_region" {
  description = "The short name for an AWS region"
  default = {
    us-west-1 = "usw1"
    us-west-2 = "usw2"
    eu-central-1	= "euc1"
    eu-west-1 = "euw1"
    eu-west-2 = "euw2"
    eu-west-3	= "euw3"
    eu-north-1	= "eun1"
    eu-south-1	= "eus1"
    us-east-1 = "use1"
    us-east-2 = "use2"
    af-south-1 = "afs1"
    ap-east-1	= "ape1"
    ap-south-1 = "aps1"
    ap-northeast-1 = "apne1"
    ap-northeast-2 = "apne2"
    ap-northeast-3 = "apne3"
    ap-southeast-1 = "apse1"
    ap-southeast-2 = "apse2"
    ca-central-1	= "cac1"
    cn-north-1	= "cnn1"
    cn-northwest-1	= "cnnw1"
    me-south-1	= "mes1"
    sa-east-1	= "sae1"
  }
}

variable "environment" {
  type = string
}

variable "project_name" {
  type = string
}

# ECS
variable "cluster_name" {
  type = string
}

variable "image_repo" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "launch_type" {
  type = string
}


variable "log_retention_days" {
  type = number
  default = 30
}

variable "container_port" {
  type = number
}

variable "health_check_path" {
  type = string
  default = "/"
}

variable "listener_port" {
  type = number
  default = 80
}

variable "path_patterns" {
  type = list(string)
}

variable "task_cpu" {
  type = number
  default = 128
}

variable "task_memory" {
  type = number
  default = 128
}

variable "subnet_names" {
  type = list(string)
}

variable "security_group_names" {
  type = list(string)
}

# Networking
variable "vpc_name" {
  type = string
}

variable "lb_name" {
  type = string
}
