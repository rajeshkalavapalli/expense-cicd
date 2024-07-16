# variable "ec2_instance" {
#   type = list
#   default = [
#     {
#   name = "jenkins-master"
#   instance_type          = "t3.small"
#   vpc_security_group_ids = ["sg-09ecc63e9ed970607"]
#   subnet_id              = "subnet-043091cc04d94c6a7"
#   },
#   {
#   name = "jenkins-node"
#   instance_type          = "t3.small"
#   vpc_security_group_ids = ["sg-09ecc63e9ed970607"]
#   subnet_id              = "subnet-0357c3fde93a75fb2"
#   }
#   ]
# }

# variable "instance_type" {
#   default = "t3.small"
# }

# variable "node_subnet" {
#   default = "subnet-0357c3fde93a75fb2"
# }

# variable "master_subnet" {
#   default = "subnet-043091cc04d94c6a7"
# }

# # variable "vpc_security_group_ids" {
# #   default = "sg-09ecc63e9ed970607"
# # }

variable "common_tags" {
  default = {
    Terraform   = "true"
    Environment = "dev"
    project= "expense"
  }
}