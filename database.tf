resource "aws_db_subnet_group" "my-db-subnet_group" {
  depends_on = [ aws_route_table.Private-Subnet-RT ]
  name        = "my-subnet-group"
  description = "My Subnet Group"
  subnet_ids  = aws_subnet.Db-private-subnet-A[*].id
  
}
#create a random generated password to use in secrets.
 
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%"
}
# Creating a AWS secret for database master account (gameshopdb)
 
resource "aws_secretsmanager_secret" "secretmasterDB" {
   name = "gameshopdb"
}
# Creating a AWS secret versions for database master account (Masteraccoundb)
 
resource "aws_secretsmanager_secret_version" "dhruvraj_gameshop_db" {
  secret_id = aws_secretsmanager_secret.secretmasterDB.id
  secret_string = jsonencode(
    {
      "DB_HOST"    : aws_db_instance.dhruvraj-gameshop-db.endpoint,
      "DB_USERNAME": "Dhruvraj",
      "DB_PASSWORD": "${random_password.password.result}",
      "DB_NAME"    : "players"

    }
  )
  
}
# Create RDS Dtabase 
resource "aws_db_instance" "dhruvraj-gameshop-db" {
  depends_on = [ aws_db_subnet_group.my-db-subnet_group ]
  identifier             = "gameshop-db"
  engine                 = "mysql"
  # engine_version         = "5.7"  
  instance_class         = "db.t3.micro"  
  allocated_storage      = 20 
  storage_type           = "gp2"
  username               = "Dhruvraj"  # Retrieve username from Secrets Manager
  password               = random_password.password.result   # Retrieve password from Secrets Manager
  db_name                = "gameshopdb" 

  vpc_security_group_ids = [aws_security_group.security-Group-rds.id]  # Update with our desired security group ID
  db_subnet_group_name   = aws_db_subnet_group.my-db-subnet_group.name
  # vpc_id                 = aws_vpc.gameshop-vpc.id
  

  parameter_group_name   = "default.mysql8.0"  # Update with your desired parameter group name

  backup_retention_period = 7
  backup_window           = "07:00-09:00"  # Update with your desired backup window
  maintenance_window      = "Mon:00:00-Mon:03:00"  # Update with your desired maintenance window

  multi_az               = false  # Set to true for Multi-AZ deployment

  tags = {
    Name = "mygameshop-db"
    Environment = "Production"
  }
}



