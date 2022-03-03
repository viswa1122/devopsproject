#https://www.terraform.io/docs/configuration-0-11/resources.html#explicit-dependencies

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}

locals {
  env  = "Prod"
  owner = "Sree"
  costcenter = 9000
}


resource "aws_vpc" "default" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags = {
        Name = "${var.vpc_name}"
        Env = "${local.env}"
        Owner = "${local.owner}"
        CC = "${local.costcenter}"
    }
    depends_on = ["aws_s3_bucket.example"] #Explicit dependency
}

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"
	tags = {
        Name = "${var.IGW_name}"
        Env = "${local.env}"
        Owner = "${local.owner}"
        CC = "${local.costcenter}"
    }
    depends_on = ["aws_s3_bucket.example"] #Explicit dependency
}

resource "aws_subnet" "subnets" {
    #count = "${length(var.cidrs)}"
    count = "${var.env!="prod" ? 1 : 3}"
    vpc_id = "${aws_vpc.default.id}" #Implicit dependency
    cidr_block = "${element(var.cidrs, count.index)}"
    availability_zone = "${element(var.azs, count.index)}"
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.vpc_name}-Subnet-${count.index+1}"
        Env = "${local.env}"
        Owner = "${local.owner}"
        CC = "${local.costcenter}"
    }
}


resource "aws_route_table" "terraform-public" {
    vpc_id = "${aws_vpc.default.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.default.id}"
    }

    tags = {
        Name = "${var.Main_Routing_Table}"
        
    }
}

resource "aws_route_table_association" "terraform-public" {
    #count = "${length(var.cidrs)}"
    count = "${var.env!="prod" ? 1 : 6}"
    subnet_id = "${element(aws_subnet.subnets.*.id,count.index)}"
    #aws_subnet.subnets.0.id
    #aws_subnet.subnets.1.id
    #aws_subnet.subnets.2.id
    route_table_id = "${aws_route_table.terraform-public.id}"
}

resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.default.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    }
}

resource "aws_s3_bucket" "example" {
  bucket = "sreedevopsclassterraform200"
  tags = {
    Time = "8PM"
  }

  lifecycle {
   create_before_destroy = true
   ignore_changes = [
       tags["Time"]
       ]
}
}
#data "aws_ami" "my_ami" {
#      most_recent      = true
#      #name_regex       = "^mavrick"
#      owners           = ["444984551434"]
#}


resource "aws_instance" "web-1" {
    #ami = "${data.aws_ami.my_ami.id}"
    #count = 1
    ami = "${lookup(var.amis, "us-east-1")}"
    instance_type = "t2.micro"
    key_name = "LaptopKey"
    subnet_id = "${aws_subnet.subnets.0.id}"
    vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
    associate_public_ip_address = true	
    tags = {
        Name = "${var.vpc_name}-Server-1"
        Env = "Prod"
        Owner = "Sree"
    }
}

resource "null_resource" "nginxinstall" {

    provisioner "remote-exec" {
    inline = [
      #"chmod +x /tmp/script.sh",
      #"sudo ./tmp/script.sh",
      "sudo yum update -y",
      "sudo yum install nginx -y",
      "sudo service nginx start"

      ]
    connection {
    type     = "ssh"
    user     = "ec2-user"
    #password = "India@123456"
    private_key = "${file("LaptopKey.pem")}"
    host     = "${aws_instance.web-1.public_ip}"
    }
    }

}

resource "null_resource" "nginxfilecopy" {

    provisioner "remote-exec" {
    inline = [
      #"chmod +x /tmp/script.sh",
      #"sudo ./tmp/script.sh",
      "sudo rm -rf /usr/share/nginx/html/index.html",
      "sudo cp /tmp/index.html /usr/share/nginx/html/",
      "sudo cp /tmp/style.css /usr/share/nginx/html/",
      "sudo cp /tmp/scorekeeper.js /usr/share/nginx/html/",
      "sudo service nginx start"

      ]
    connection {
    type     = "ssh"
    user     = "ec2-user"
    #password = "India@123456"
    private_key = "${file("LaptopKey.pem")}"
    host     = "${aws_instance.web-1.public_ip}"
    }
    }
    depends_on = ["null_resource.filecopy"]
}

resource "null_resource" "filecopy" {

    provisioner "file" {
    source      = "scorekeeper.js"
    destination = "/tmp/scorekeeper.js"

    connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = "${file("LaptopKey.pem")}"
    host     = "${aws_instance.web-1.public_ip}"
  }
}
provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"

    connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = "${file("LaptopKey.pem")}"
    host     = "${aws_instance.web-1.public_ip}"
  }
}
provisioner "file" {
    source      = "style.css"
    destination = "/tmp/style.css"

    connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = "${file("LaptopKey.pem")}"
    host     = "${aws_instance.web-1.public_ip}"
  }
}
depends_on = ["null_resource.nginxinstall"]
}

resource "null_resource" "instancedetails" {

    provisioner "local-exec" {
    command = <<EOH
    echo "${aws_instance.web-1.public_ip}" >> details && echo "${aws_instance.web-1.private_ip}" >> details && echo "${aws_instance.web-1.public_dns}" >> details
    EOH
  }
    
    depends_on = ["aws_instance.web-1"]
}

#output "ami_id" {
#  value = "${data.aws_ami.my_ami.id}"
#}
