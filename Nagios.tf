resource "aws_security_group" "nagios_sg" {
  name = "nagios-security-group"
  description = "Security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id = "${module.vpc.vpc_id}"
  
  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["115.110.137.30/32"]
  }

  ingress {
    from_port = "80"
    to_port   = "80"
    protocol  = "tcp"
    cidr_blocks = ["115.110.137.30/32"]
  }
  ingress {
    from_port = "5666"
    to_port   = "5666"
    protocol  = "tcp"
    cidr_blocks = ["115.110.137.30/32"]
  }
  ingress {
    from_port = "-1"
    to_port   = "-1"
    protocol  = "icmp"
    cidr_blocks = ["115.110.137.30/32","10.0.0.0/16","20.0.0.0/16"]
  }

 
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

  tags { 
    Name = "NagiosSG" 
  }
}

resource "aws_instance" "Nagios_Server" {
  count                  = 1
  ami                    = "ami-90e8d0f5"
  instance_type          = "t2.micro"
  security_groups = ["${aws_security_group.nagios_sg.id}"]
  monitoring             = false
  subnet_id              = "${element(module.vpc.public_subnets,1)}"
  vpc_security_group_ids = ["${module.security_group.this_security_group_id}"]
  associate_public_ip_address = true

  
  connection {
    host = "${self.public_ip}"
    type     = "ssh"
    user     = "${var.agility_username}"
    password = "${var.agility_password}"
	
    }
	
  /*provisioner "file" {
	source      = "nagios_server_install.sh"
	destination = "/home/smadmin/nagios_server_install.sh"

  connection {
    type     = "ssh"
    user     = "${var.agility_username}"
    password = "${var.agility_password}"
  }
}
*/

  provisioner "remote-exec" {
   
    inline = [
		"password='demo'",
		"sudo useradd nagios",
		"sudo groupadd nagcmd",
		"sudo usermod -a -G nagcmd nagios",
		"sudo yum install httpd php gcc glibc glibc-common gd  make net-snmp openssl-devel xinetd unzip -y ",
		"mkdir nagios",
		"cd /home/smadmin/nagios",
		"curl -L -O https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.4.1.tar.gz",
		"tar -xzvf nagios-4.4.1.tar.gz",
		"cd nagios-4.4.1",
		"./configure --with-command-group=nagcmd",
		"sudo make all",
		"sudo make install",
		"sudo make install-commandmode",
		"sudo make install-init",
		"sudo make install-config",
		"sudo make install-webconf",
		"sudo htpasswd -b -c /usr/local/nagios/etc/htpasswd.users nagiosadmin $password ",
		"sudo usermod -G nagcmd apache",
		"sudo service httpd start ",
		"cd /home/smadmin/nagios",
		"curl -L -O http://nagios-plugins.org/download/nagios-plugins-2.2.1.tar.gz",
		"tar -xzvf nagios-plugins-*.tar.gz",
		"cd nagios-plugins-2.2.1",
		"./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl",
		"sudo make",
		"sudo make install",
		"sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg",
		"sudo service nagios start",
		"sudo chkconfig --add nagios",
		"sudo chkconfig --level 35 nagios on",
		"sudo chkconfig --add httpd",
		"sudo chkconfig --level 35 httpd on",
		"sudo service httpd start",
      
	  
    ]
  }

   tags ={
	Name = "Nagios_Server",
	SkipStop="AlwaysOn"
  }

}
  