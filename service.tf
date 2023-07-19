resource "aws_ecs_service" "gameshop-service" {
  depends_on = [
    aws_lb.gameshop_load_balancer,
    aws_lb_listener.gameshop-alb-listener,
    aws_lb_target_group.gameshop_target_group,
  ]

  name            = "gameshop-service"
  cluster         = aws_ecs_cluster.gameshop-cluster.id
  task_definition = aws_ecs_task_definition.gameshop-task-def.arn
  desired_count   = 1

  launch_type = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.my_security_group.id]
    subnets         = aws_subnet.private-subnet-A[*].id
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.gameshop_target_group.arn
    container_name   = "backend"
    container_port   = 3001
  }
}
