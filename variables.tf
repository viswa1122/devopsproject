variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}
variable "amis" {
    description = "AMIs by region"
    default = {
    us-east-1 = "ami-00eb20669e0990cb4" # ubuntu 14.04 LTS
		us-east-2 = "ami-0c64dd618a49aeee8" # ubuntu 14.04 LTS
		us-west-1 = "ami-824c4ee2" # ubuntu 14.04 LTS
		us-west-2 = "ami-f2d3638a" # ubuntu 14.04 LTS
    }
}
variable "vpc_cidr" {}
variable "vpc_name" {}
variable "IGW_name" {}
variable "key_name" {}
variable "public_subnet1_cidr" {}
variable "public_subnet2_cidr" {}
variable "public_subnet3_cidr" {}
variable "private_subnet_cidr" {}
variable "public_subnet1_name" {}
variable "public_subnet2_name" {}
variable "public_subnet3_name" {}
variable "private_subnet_name" {}
variable Main_Routing_Table {}
variable "azs" {
  description = "Run the EC2 Instances in these Availability Zones"
  type = "list"
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
  #               0                1             2             3             4             5
}

variable "cidrs" {
  description = "CIDR Blocks for Subnets"
  type = "list"
  default = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
  #               0                1             2
}
variable "env" {}
variable "instance_type" {
  type = "map"
  default = {
    dev = "t2.nano"
    test = "t2.micro"
    prod = "t2.medium"
    }
}


