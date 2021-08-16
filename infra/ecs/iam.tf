
resource "aws_iam_role" "task_execution_role" {
  name = "rearc-quest-task-role-${local.short_region}-${var.environment}"
  description = "Rearc quest projecttask role."
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "task_execution_policy" {
  name = "rearc-quest-task-policy${local.short_region}-${var.environment}"
  path        = "/"
  description = "Rearc quest project task policy."

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
          "Sid": "ECSTaskManagement",
          "Effect": "Allow",
          "Action": [
              "ec2:AttachNetworkInterface",
              "ec2:CreateNetworkInterface",
              "ec2:CreateNetworkInterfacePermission",
              "ec2:DeleteNetworkInterface",
              "ec2:DeleteNetworkInterfacePermission",
              "ec2:Describe*",
              "ec2:DetachNetworkInterface"
          ],
          "Resource": "*",
          "Condition": {
              "StringEquals": {
                "ec2:Vpc": local.vpc_id,
                "ec2:Subnet": local.subnet_arns,
                "ec2:AuthorizedService": "ecs.amazonaws.com"
              }
            }
        },
        {
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:logs:${var.aws_region}:${local.account_id}:log-group:ecs/${var.project_name}-usw2-${var.environment}*"
            ],
            "Sid": "Logs"
        },
        {
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability"
            ],
            "Effect": "Allow",
            "Resource": ["arn:aws:ecr:${var.aws_region}:${local.account_id}:repository/${var.image_repo}"],
            "Sid": "ECRReadOnly"
        },
        {
          "Action": [
              "ecr:GetAuthorizationToken"
          ],
          "Effect": "Allow",
          "Resource": "*",
          "Sid": "ECRToken"
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_policy.arn
}