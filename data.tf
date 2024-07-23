# data "aws_ami" "expense" {
#   owners           = ["973714476881"]

#   filter {
#     name   = "name"
#     values = ["RHEL-9-DevOps-Practice"]
#   }

#   filter {
#     name   = "root-device-type"
#     values = ["ebs"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
# }


#nexus
data "aws_ami" "nexus" {
  owners           = ["679593333241"]

  filter {
    name   = "name"
    values = ["SolveDevOps-Nexus-Server-Ubuntu20.04-20240511-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}