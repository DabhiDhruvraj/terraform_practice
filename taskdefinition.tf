resource "aws_iam_role" "gameshop-ecs-task-execution-role" {
  name = "gameshop-ecs-task-execution-role"

  assume_role_policy = <<POLICY
{
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
}
POLICY
}

resource "aws_iam_role_policy_attachment" "gameshop-ecs-task-execution-role-policy" {
  role       = aws_iam_role.gameshop-ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "gameshop-ecs-task-execution-role-admin-access" {
  role       = aws_iam_role.gameshop-ecs-task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role" "gameshop-task-role" {
  name = "gameshop-task-role"

  assume_role_policy = <<POLICY
{
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
}
POLICY
}

resource "aws_iam_role_policy_attachment" "gameshop-task-role-policy" {
  role       = aws_iam_role.gameshop-task-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "gameshop-task-role-policy2" {
  role       = aws_iam_role.gameshop-task-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "gameshop-task-role-policy3" {
  role       = aws_iam_role.gameshop-task-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_iam_role_policy_attachment" "gameshop-task-role-policy5" {
  role       = aws_iam_role.gameshop-task-role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_cloudwatch_log_group" "gameshop-logs" {
  name = "gameshop-logs"
}

data "aws_ecr_repository" "gameshop-backend_repository" {
  name = aws_ecr_repository.gameshop-backend_repository.name
}

data "aws_db_instance" "dhruvraj-gameshop-db" {
  db_instance_identifier = aws_db_instance.dhruvraj-gameshop-db.identifier
}

data "aws_db_instance" "dhruvraj-gameshop-db-endpoint" {
  db_instance_identifier = aws_db_instance.dhruvraj-gameshop-db.identifier
}

resource "aws_ecs_task_definition" "gameshop-task-def" {
  family                   = "gameshop-task-definition"
  execution_role_arn       = aws_iam_role.gameshop-ecs-task-execution-role.arn
  task_role_arn            = aws_iam_role.gameshop-task-role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096

    container_definitions = <<CONTAINER_DEFINITIONS
[
  {
    "name": "backend",
    "image": "${data.aws_ecr_repository.gameshop-backend_repository.repository_url}",
    "cpu": 0,
    "portMappings": [
      {
        "name": "backend-3001-tcp",
        "containerPort": 3001,
        "hostPort": 3001,
        "protocol": "tcp",
        "appProtocol": "http"
      }
    ],
    "essential": true,
    "environment": [],
    "secrets": [
      {
        "name": "DB_HOST",
        "valueFrom": "${aws_secretsmanager_secret_version.dhruvraj_gameshop_db.arn}:DB_HOST::"
      },
      {
        "name": "DB_USERNAME",
        "valueFrom": "${aws_secretsmanager_secret_version.dhruvraj_gameshop_db.arn}:DB_USERNAME::"
      },
      {
        "name": "DB_PASSWORD",
        "valueFrom": "${aws_secretsmanager_secret_version.dhruvraj_gameshop_db.arn}:DB_PASSWORD::"
      },
      {
        "name": "DB_NAME",
        "valueFrom": "${aws_secretsmanager_secret_version.dhruvraj_gameshop_db.arn}:DB_NAME::"
      }

    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-create-group": "true",
        "awslogs-group": "/ecs/cm-test-td",
        "awslogs-region": "us-east-1",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
CONTAINER_DEFINITIONS

  depends_on = [
    aws_cloudwatch_log_group.gameshop-logs,
    aws_iam_role_policy_attachment.gameshop-task-role-policy,
    aws_iam_role_policy_attachment.gameshop-task-role-policy2,
    aws_iam_role_policy_attachment.gameshop-task-role-policy3,
    aws_iam_role_policy_attachment.gameshop-task-role-policy5
  ]
}
