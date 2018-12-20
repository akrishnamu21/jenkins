
resource "aws_instance" "ec2_jenkins_master" {
  count                  = 1
  ami                    = "ami-90e8d0f5"
  instance_type          = "t2.micro"
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

  provisioner "remote-exec" {
   
    inline = [
      "echo 'updating'",
	  "sudo yum -y update",
	  "echo 'installing java'",
	  "sudo yum -y install java-1.8.0",
	  "sudo java -version",
	  "sudo yum install -y git",
	  "sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo",
      #"sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo",
	  "sudo yum install -y apache-maven",
	  "sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo",
	  "sudo rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key",
	  "sudo yum -y install jenkins",
	  "sudo service jenkins start",
	  "sudo chkconfig --add jenkins",
	  "sudo cat /var/lib/jenkins/secrets/initialAdminPassword",
	  "echo 'Jenkins installation completed'",
	  "installing terraform ",
	  "sudo wget https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip",
	  "sudo unzip terraform_0.11.10_linux_amd64.zip",
	  "sudo mv terraform /usr/local/bin/",
	  "terraform --version",
	  
    ]
  }

   tags ={
	Name = "Jenkins_Server",
	SkipStop="AlwaysOn"
  }

}
  