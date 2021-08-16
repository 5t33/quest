resource "aws_security_group" "quest_alb_sg" {
  name        = "quest_alb_sg"
  description = "Security group for quest alb"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "quest_alb_sg_ingress_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.quest_alb_sg.id
}

resource "aws_security_group_rule" "quest_alb_sg_ingress_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.quest_alb_sg.id
}


resource "aws_security_group_rule" "quest_alb_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.quest_alb_sg.id
}


resource "aws_security_group" "quest_alb_downstream_sg" {
  name        = "quest_alb_downstream_sg"
  description = "Security group for downstream applications of quest alb"
  vpc_id      = module.vpc.vpc_id
  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "quest_alb_downstream_sg_ingress" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  security_group_id = aws_security_group.quest_alb_downstream_sg.id
  source_security_group_id = aws_security_group.quest_alb_sg.id
}


resource "aws_security_group_rule" "quest_alb_downstream_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.quest_alb_downstream_sg.id
}


