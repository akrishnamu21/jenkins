# aws credentials details

provider "aws" {
access_key 	= "${var.access_key}"
secret_key 	= "${var.secret_key}"
region 		= "${var.region}"
}

# aws management vpc resource details

module "vpc" {
  source  		  = "terraform-aws-modules/vpc/aws"
  #version 	  	  = "1.4.0"
  name 			  = "management_vpc_new"
  cidr 			  = "${var.management_vpc_cidr}"
  enable_dns_support = "true"
  enable_nat_gateway = "false"
  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.2.0/24"]
  
  tags = {
    Owner         = "terraform"
    Environment   = "Management"
  }
  vpc_tags = {
    Name          = "management_vpc_new"
  }
}

resource "aws_eip" "nat_gw" {
  count = "1"
}
resource "aws_nat_gateway" "nat_gw" {
  count = "1"
  allocation_id = "${element(aws_eip.nat_gw.*.id,count.index)}"
  subnet_id = "${element(module.vpc.public_subnets,count.index)}"
}
resource "aws_route" "nat_gw" {
  #count = "3"
  route_table_id = "${element(module.vpc.private_route_table_ids,count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${element(aws_nat_gateway.nat_gw.*.id,count.index%3)}"
}

module "security_group" {
  source			 	= "terraform-aws-modules/security-group/aws"
  name				 	= "jenkins-sg"
  description 		 	= "Security group for example usage with EC2 instance"
  vpc_id     		 	= "${module.vpc.vpc_id}"
  ingress_cidr_blocks   = ["0.0.0.0/0"]
  ingress_rules         = ["http-8080-tcp", "ssh-tcp"]
  egress_rules          = ["all-all"]
}

module "security_group_bastion_host"  {
  source				= "terraform-aws-modules/security-group/aws//modules/rdp"
  name				 	= "bastion_host_sg"
  description 		 	= "Security group for example usage with EC2 instance"
  vpc_id     		 	= "${module.vpc.vpc_id}"
  ingress_cidr_blocks   = ["0.0.0.0/0"]
  
}

/*module "ec2-instance_private" {
  source  					  = "terraform-aws-modules/ec2-instance/aws"
  version 					  = "1.9.0"
  name    					  = "private"
  instance_count 			  = 1
  ami     					  = "ami-adf38ed5"
  instance_type 			  = "t2.micro"
  subnet_id                   = "${element(module.vpc.private_subnets,1)}"
  vpc_security_group_ids      = ["${module.security_group.this_security_group_id}"]
  associate_public_ip_address = false
}
*/


resource "aws_instance" "Bastion_host" {
  
  ami     					  = "ami-5fe9d13a"
  instance_type 			  = "t2.micro"
  subnet_id                   = "${element(module.vpc.public_subnets,1)}"
  vpc_security_group_ids      = ["${module.security_group.this_security_group_id}","${module.security_group_bastion_host.this_security_group_id}"]
  associate_public_ip_address = true
 /* provisioner "remote-exec" {
    connection {
    host = "${self.public_ip}"
    type     = "ssh"
    user     = "${var.agility_username}"
    password = "${var.agility_password}"
    }
    inline = [
      "echo 'Bastion host connection successfull'",
    ]
  }*/
  tags ={
	Name = "Bastion_host",
	SkipStop = "AlwaysOn"
  }
}
