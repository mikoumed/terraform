provider "aws" {
	region = "us-east-2"
	}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port = var.server_port
    to_port   = var.server_port
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "alb" {
  name = "terraform-example-alb"
  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "example" {
  name = "terraform-asg-example"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default.ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100  

  condition {
    field = "path-pattern"
    values = ["*"]
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}


resource "aws_lb_target_group" "asg" {
  name = "terraform-asg-example"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}


resource "aws_launch_configuration" "example" {
  image_id 			= "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  security_groups = [ aws_security_group.instance.id ]

  user_data = data.template_file.user_data.rendered
  
  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "user_data" {
  template = file("user-data.sh")

  # vars = {
  #   server_port = var.server_port
  #   db_address = data.terraform_remote_state.db.outputs.adress
  #   db_port = data.terraform_remote_state.db.outputs.port
  # }
}
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnet_ids.default.ids
  
  target_group_arns = [aws_lb_target_group.asg.arn]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

# data "terraform_remote_state" "db" {
#   backend = "s3"

#   config = {
#     bucket = "(terraform-up-and-running-state)"
#     key = "stage/data-stores/mysql/terraform.tfstate"
#     region = "us-east-2"
#   }
# }

# terraform {
#     backend "s3" {
#         bucket = "a-terraform-state-s3"
#         key = "stage/service/webserver-cluster/terraform.tfstate"
#         region = "us-east-2"

#         dynamodb_table = "my-terraform-locks-dynamoDB"
#         encrypt = true
#     }
# }