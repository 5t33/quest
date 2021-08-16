# AWS
variable "aws_profile" {
  type = string
}

variable "aws_region" {
  type = string
}

# Mic

variable "environment" {
  type = string
  default = "tst"
}

# VPC

variable "vpc_name" {
  type = string
}

# ALB

variable "alb_name" {
  type = string
}

variable "website_name" {
  type = string
}