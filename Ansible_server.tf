
resource "aws_instance" "ansible_Server" {
  count                  = 1
  ami                    = "ami-90e8d0f5"
  instance_type          = "t2.micro"
  #user_data              = "${file("Jenkins_install.sh")}"
  monitoring             = false
  subnet_id              = "${element(module.vpc.private_subnets,1)}"
  vpc_security_group_ids = ["${module.security_group.this_security_group_id}"]
  associate_public_ip_address = false
  depends_on = ["aws_instance.Nagios_Server"], 
  
  connection {
    host = "${self.private_ip}"
    type     = "ssh"
    user     = "${var.agility_username}"
    password = "${var.agility_password}"
	bastion_host = "${aws_instance.Nagios_Server.public_ip}"
    bastion_user = "${var.agility_username}"
    bastion_password = "${var.agility_password}"
    bastion_port = 22
    }

  provisioner "remote-exec" {
   
    inline = [
      "sudo wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm",
	  "sudo rpm -ivh epel-release-6-8.noarch.rpm",
	  "sudo yum repolist",
	  "sudo yum install ansible -y",
	  "sudo ansible --version",
	  "echo 'Ansible server is installed'",
	  "echo 'generating ssh key'",
	  "ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa",
	 
    ]
  }

   tags ={
	Name = "Ansible_Server",
	SkipStop = "AlwaysOn"
  }

}
  