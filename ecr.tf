resource "aws_ecr_repository" "gameshop-backend_repository" {
  name = "gameshop-repo"
}

resource "aws_ecr_repository_policy" "gameshop_repository_policy" {
  repository = aws_ecr_repository.gameshop-backend_repository.name

  policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "AllowPull",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }
  ]
}
EOF
}

data "aws_ecr_authorization_token" "current" {}

resource "null_resource" "docker_login" {
  provisioner "local-exec" {
    command = "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${aws_ecr_repository.gameshop-backend_repository.repository_url}"
  }
}

resource "null_resource" "docker_push" {
  depends_on = [null_resource.docker_login]

  provisioner "local-exec" {
    command = "docker tag dhruvrajsinh-gameshop:latest ${aws_ecr_repository.gameshop-backend_repository.repository_url}:latest && docker push ${aws_ecr_repository.gameshop-backend_repository.repository_url}:latest"
    
  }

}
