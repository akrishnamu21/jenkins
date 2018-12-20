/*module "customervpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "CustomerVpc"
  cidr = "20.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["20.0.2.0/24", "20.0.3.0/24"]
  public_subnets  = ["20.0.1.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true
  enable_dns_hostnames = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

module "mysql_server_sg" {
  source = "terraform-aws-modules/security-group/aws/modules/mysql"

  name        = "mysql_server_securityGroup"
  description = "Security group for mysql with sql ports open within VPC"
  vpc_id      = "${module.customervpc.vpc_id}"

  ingress_cidr_blocks = ["20.0.0.0/16"]
}


resource "aws_security_group" "webserver_sg" {
  name        = "webserver_securityGroup"
  description = "Security group for http with web ports open within VPC"
  vpc_id      = "${module.customervpc.vpc_id}"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["115.110.137.30/32","20.0.0.0/16","10.0.0.0/16"]
  }
  ingress {
    from_port = "-1"
    to_port   = "-1"
    protocol  = "icmp"
    cidr_blocks = ["115.110.137.30/32","10.0.0.0/16","20.0.0.0/16"]
  }
}

resource "aws_security_group" "elb_sg" {
  name        = "elb_securityGroup"
  description = "Allow all inbound traffic"
  vpc_id      = "${module.customervpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["115.110.137.30/32","20.0.0.0/16","10.0.0.0/16"]
  }
}

resource "aws_security_group" "elb_attaching_sg" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "${module.customervpc.vpc_id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = ["${aws_security_group.elb_sg.id}"]
  }
}



module "ssh_sg" {
  source = "terraform-aws-modules/security-group/aws//modules/ssh"

  name        = "ssh_securityGroup"
  description = "Security group for http with web ports open within VPC"
  vpc_id      = "${module.customervpc.vpc_id}"

  ingress_cidr_blocks = ["20.0.0.0/16","115.110.137.30/32","54.146.32.215/32","10.0.0.0/16"]
}

module "ec2-MysqlDev" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "MySqlDev/QA"
  instance_type          = "t2.medium"
  ami 			 = "ami-adf38ed5"
  subnet_id = "${module.customervpc.private_subnets[1]}"
  vpc_security_group_ids = ["${module.ssh_sg.this_security_group_id}","${module.mysql_server_sg.this_security_group_id}"]
  associate_public_ip_address = false 
  
}

module "ec2-MysqlProd" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "MySqlDev/Prod"
  instance_type          = "t2.medium"
  ami 			 = "ami-adf38ed5"
  subnet_id = "${module.customervpc.private_subnets[1]}"
  vpc_security_group_ids = ["${module.ssh_sg.this_security_group_id}","${module.mysql_server_sg.this_security_group_id}"]
  associate_public_ip_address = false 
  
}

module "ec2-DevWebServer" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "DevWebServer"
  instance_type          = "t2.medium"
  ami 			 = "ami-4934ea31"
  subnet_id = "${module.customervpc.private_subnets[0]}"
  vpc_security_group_ids = ["${module.ssh_sg.this_security_group_id}","${module.mysql_server_sg.this_security_group_id}","${aws_security_group.webserver_sg.id}"]
  associate_public_ip_address = false 
  
}
module "ec2-QAWebServer" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "QAWebServer"
  instance_type          = "t2.medium"
  ami 			 = "ami-4934ea31"
  subnet_id = "${module.customervpc.private_subnets[0]}"
  vpc_security_group_ids = ["${module.ssh_sg.this_security_group_id}","${module.mysql_server_sg.this_security_group_id}","${aws_security_group.webserver_sg.id}"]
  associate_public_ip_address = false 
  
}

module "ec2-ProdWebServer" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "ProdWebServer"
  instance_type          = "t2.medium"
  ami 			 = "ami-4934ea31"
  subnet_id = "${module.customervpc.public_subnets[0]}"
  vpc_security_group_ids = ["${module.ssh_sg.this_security_group_id}","${module.mysql_server_sg.this_security_group_id}","${aws_security_group.elb_attaching_sg.id}","${aws_security_group.webserver_sg.id}"]
  associate_public_ip_address = true 
  
}

module "ec2-ProdWebServer2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "ProdWebServer2"
  instance_type          = "t2.medium"
  ami 			 = "ami-4934ea31"
  subnet_id = "${module.customervpc.public_subnets[0]}"
  vpc_security_group_ids = ["${module.ssh_sg.this_security_group_id}","${module.mysql_server_sg.this_security_group_id}","${aws_security_group.elb_attaching_sg.id}","${aws_security_group.webserver_sg.id}"]
  associate_public_ip_address = true 
 
  
}

resource "null_resource" "mysqlfileCopy"
{

provisioner "file" {

  source      = "C:/Terraform/mySql/MySqlRpm.tar"
  destination = "/home/smadmin/MySqlRpm.tar"

  
  connection {
    type     = "ssh"
	bastion_host = "${module.ec2-ProdWebServer.public_ip}"
	bastion_user = "smadmin"
	bastion_password = "M3sh@dmin!"
    host     = "${module.ec2-MysqlDev.private_ip}"
    user     = "smadmin"
    password = "M3sh@dmin!"
  }
 }

provisioner "remote-exec" {
    inline = [
      "tar -xvf /home/smadmin/MySqlRpm.tar",
      "chmod +x /home/smadmin/mysql_install.sh",
      "/home/smadmin/mysql_install.sh",
    ]
 connection {
    type     = "ssh"
	bastion_host = "${module.ec2-ProdWebServer.public_ip}"
	bastion_user = "smadmin"
	bastion_password = "M3sh@dmin!"
    host     = "${module.ec2-MysqlDev.private_ip}"
    user     = "smadmin"
    password = "M3sh@dmin!"
  }

  }
}

resource "null_resource" "ProdMysql"
{

provisioner "file" {

  source      = "C:/Terraform/mySql/MySqlRpm.tar"
  destination = "/home/smadmin/MySqlRpm.tar"

  
  connection {
    type     = "ssh"
	bastion_host = "${module.ec2-ProdWebServer.public_ip}"
	bastion_user = "smadmin"
	bastion_password = "M3sh@dmin!"
    host     = "${module.ec2-MysqlProd.private_ip}"
    user     = "smadmin"
    password = "M3sh@dmin!"
  }
 }

provisioner "remote-exec" {
    inline = [
      "tar -xvf /home/smadmin/MySqlRpm.tar",
      "chmod +x /home/smadmin/mysql_install.sh",
      "/home/smadmin/mysql_install.sh",
    ]
 connection {
    type     = "ssh"
	bastion_host = "${module.ec2-ProdWebServer.public_ip}"
	bastion_user = "smadmin"
	bastion_password = "M3sh@dmin!"
    host     = "${module.ec2-MysqlProd.private_ip}"
    user     = "smadmin"
    password = "M3sh@dmin!"
  }

  }
}

resource "null_resource" "httpdDevInstall"
{
   
provisioner "remote-exec" {
    inline = [
      "docker run --name 'ankitTomcat' -it -dp 8080:8080 tomcat:8.0"
    ]
 connection {
    type     = "ssh"
	bastion_host = "${module.ec2-ProdWebServer.public_ip}"
	bastion_user = "smadmin"
	bastion_password = "M3sh@dmin!"
    host     = "${module.ec2-DevWebServer.private_ip}"
    user     = "smadmin"
    password = "M3sh@dmin!"
  }

  }
}

resource "null_resource" "httpdQAInstall"
{


provisioner "remote-exec" {
    inline = [
      "docker run --name 'ankitTomcat' -it -dp 8080:8080 tomcat:8.0"
    ]
 connection {
    type     = "ssh"
	bastion_host = "${module.ec2-ProdWebServer.public_ip}"
	bastion_user = "smadmin"
	bastion_password = "M3sh@dmin!"
    host     = "${module.ec2-QAWebServer.private_ip}"
    user     = "smadmin"
    password = "M3sh@dmin!"
  }

  }
}

resource "null_resource" "httpdProdInstall"
{

provisioner "remote-exec" {
    inline = [
      "docker run --name 'ankitTomcat' -it -dp 8080:8080 tomcat:8.0"
    ]
 connection {
    type     = "ssh"
    host     = "${module.ec2-ProdWebServer.public_ip}"
    user     = "smadmin"
    password = "M3sh@dmin!"
  }

  }
}

resource "null_resource" "httpdProdInstall2"
{

provisioner "remote-exec" {
    inline = [
      "docker run --name 'ankitTomcat' -it -dp 8080:8080 tomcat:8.0"
    ]
 connection {
    type     = "ssh"
    host     = "${module.ec2-ProdWebServer2.public_ip}"
    user     = "smadmin"
    password = "M3sh@dmin!"
  }

  }
}

module "elb_http" {
  source = "terraform-aws-modules/elb/aws"

  name = "ProdServerELB"

  subnets         = ["${module.customervpc.public_subnets[0]}"]
  security_groups = ["${aws_security_group.elb_sg.id}"]
  internal        = false
  connection_draining = true
  

  listener = [
    {
      instance_port     = "8080"
      instance_protocol = "HTTP"
      lb_port           = "8080"
      lb_protocol       = "HTTP"
    },
  ]

  health_check = [
    {
      target              = "HTTP:8080/index.html"
      interval            = 10
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
    },
  ]

 
  // ELB attachments ec2-ProdWebServer
  number_of_instances = 2
  instances           = ["${module.ec2-ProdWebServer.id}","${module.ec2-ProdWebServer2.id}"]

  tags = {
    Owner       = "Ankit"
    Environment = "Prod"
  }
}*/


