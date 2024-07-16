module "master" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-master"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-09ecc63e9ed970607"]
  subnet_id              = "subnet-043091cc04d94c6a7"
  ami                    = "ami-041e2ea9402c46c32"
  user_data = file("jenkins.sh")

  tags = merge(
    var.common_tags,
    {
      Name = "jenkins-master"
    }
  )
}


module "nexus" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "nexus"

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-09ecc63e9ed970607"]
  subnet_id              = "subnet-043091cc04d94c6a7"
  ami                    = "ami-041e2ea9402c46c32"
  key_name = aws_key_pair.deployer.key_name
  root_block_device = [
    {
      volume_type = "gp3"
      volume_size =30
    }
  ]
  tags = merge(
    var.common_tags,
    {
      Name = "nexus"
    }
  )
}

module "agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = "jenkins-node"


  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-09ecc63e9ed970607"]
  subnet_id              = "subnet-043091cc04d94c6a7"
  ami                    = "ami-041e2ea9402c46c32"
  user_data = file("jenkins-agent.sh")

   tags = merge(
    var.common_tags,
    {
      Name = "jenkins-node"
    }
  )
}

resource "aws_key_pair" "deployer" {
  key_name   = "minikube"
  public_key = file("~/.ssh/minikube.pub")
}