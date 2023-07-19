resource "aws_autoscaling_group" "gameshop_asg" {

  name = "GameshopASG"

  desired_capacity = 1 

  min_size = 1 

  max_size = 4

  launch_template {

    id      = aws_launch_template.gameshop_launch_template.id
    version = "$Latest"
  }

  vpc_zone_identifier = aws_subnet.private-subnet-A[*].id

}



resource "aws_launch_template" "gameshop_launch_template" {

  name          = "gameshop_launch_Template"
  image_id      = "ami-06ca3ca175f37dd66" 
  instance_type = "t3.2xlarge"            

  vpc_security_group_ids = [aws_security_group.my_security_group.id]

}

resource "aws_ecs_cluster" "gameshop-cluster" {
  name = "gameshopCluster"
  
}

resource "aws_ecs_capacity_provider" "gameshop-capacity-provider" {
  name                 = "gameshop_capacity_provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.gameshop_asg.arn

    managed_scaling {
      target_capacity = 75
    }
  }
  
  tags = {
    Environment = "production"
  }
}

# resource "aws_ecs_cluster_capacity_provider_association" "example" {
#   cluster            = aws_ecs_cluster.gameshop-cluster.id
#   capacity_provider  = aws_ecs_capacity_provider.gameshop-capacity-provider.name
# }