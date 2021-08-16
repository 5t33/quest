
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "${var.alb_name}-${var.environment}"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.quest_alb_sg.id]

  target_groups = [
    {
      backend_protocol = "HTTP"
      backend_port     = 80
    },
     {
      backend_protocol = "HTTPS"
      backend_port     = 443
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      target_group_index = 1
      certificate_arn    = aws_acm_certificate.cert.arn
    }
  ]

  http_tcp_listeners = [
    {
      port              = 80
      protocol          = "HTTP"
      target_group_index = 0
    }
  ]

  http_tcp_listener_rules = [
    {
      priority = 100
      http_tcp_listener_index = 0
      conditions = [
        {
          path_patterns = ["/"]
        } 
      ]
      actions = [
        {
          type = "fixed-response"
          content_type  = "text/plain"
          status_code   = "404"
          message_body  = "Content Not Found"
        }
      ]
      http_tcp_listener_index = 0
    }
  ]

  https_listener_rules = [
    {
      priority = 100
      http_tcp_listener_index = 0
      conditions = [
        {
           path_patterns = ["/"]
        } 
      ]
      actions = [
        {
          type = "fixed-response"
          content_type  = "text/plain"
          status_code   = "404"
          message_body  = "Content Not Found"
        }
      ]
      http_tcp_listener_index = 0
    }
  ]

  tags = {
    Environment = var.environment
    Terraform   = "true"
  }
}