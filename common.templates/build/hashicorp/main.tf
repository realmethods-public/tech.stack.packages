#if( ${containerObject} )
#set( $appName = "Container-${containerObject.getName()}" )
#else
#set( $appName = $aib.getApplicationNameFormatted() )
#end
#set( $dbEngine = ${aib.getParam("terraform.db-engine")} )
# Specify the provider and access details
provider "aws" {
  region     = "${aib.getParam("terraform.region")}"
  access_key = "${var.aws-access-key}"
  secret_key = "${var.aws-secret-key}"
  version = "~> 2.0"
}

#outputAWSKeyPairDecl()

#set( $aws-vpc = ${aib.getParam("terraform.aws-vpc")} )
#if ( ${aws-vpc.isEmpty()} == true ) ## use the default
#set( $aws-vpc = "${esc.dollar}{aws_vpc.default.id}" )
# Default vpc
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}
#end

# Default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "web" {
#  name        = "${appName}-security-group-from-terrorform" #optional, when omitted, terraform creates a random name
  description = "security group for ${appName} web created from terraform"
  vpc_id      = "${aws-vpc}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our default security group to for the database
resource "aws_security_group" "rds" {
  description = "security group for ${appName} RDS created from terraform"
  vpc_id      = "${aws-vpc}"

  # mysql access from anywhere
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#set( $dbEngine = ${aib.getParam("terraform.db-engine")} )
#set( $dbVersion = ${aib.getParam("terraform.db-version")} )
resource "aws_db_instance" "default" {
  depends_on             = ["aws_security_group.rds"]
#  identifier             = "${appName}-rds" # Terraform will create a unique id if not assigned
  allocated_storage      = "10"
  engine                 = "${dbEngine}"
  engine_version         = "${dbVersion}"
  instance_class         = "${aib.getParam("terraform.aws-db-instance-type")}"
  name                   = "${appName}"
  username               = "${aib.getParam("hibernate.hibernate.connection.username")}"
  password               = "${aib.getParam("hibernate.hibernate.connection.password")}"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
}

resource "aws_instance" "web" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "ubuntu"
    private_key = "${tls_private_key.generated.private_key_pem}"
  }

  instance_type = "${aib.getParam("terraform.aws-ec2-instance-type")}"
  
  tags = { Name = "${appName} instance" } 

  # standard realmethods community AMI with docker pre-installed
  ami = "ami-05033408e5e831fb0"

  # The name of the  SSH keypair you've created and downloaded
  # from the AWS console.
  #
  # https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#KeyPairs:
  #
  # key_name = "${aib.getParam("terraform.aws-key-pair-name")}"
  key_name = "${aws_key_pair.generated.key_name}"
  
  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${aws_security_group.web.id}"]

#set( $dockerUserName = ${aib.getParam("terraform.docker-username")} ) 
#set( $dockerPassword = ${aib.getParam("terraform.docker-password")} )
#set( $dockerOrgName = ${aib.getParam("terraform.docker-org-name")} )
#set( $dockerRepo = ${aib.getParam("terraform.docker-repo")} )
#set( $dockerTag = ${aib.getParam("terraform.docker-tag")} )
#set( $databaseUrl = "jdbc:${dbEngine}://${esc.dollar}{aws_db_instance.default.endpoint}/${appName}" )
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo docker login --username ${dockerUserName} --password ${dockerPassword}",
      "sudo docker pull ${dockerOrgName}/${dockerRepo}:${dockerTag}",
      "sudo docker run -it -p 8000:8000 -p 8080:8080 -e DATABASE_URL=${databaseUrl} ${dockerOrgName}/${dockerRepo}:${dockerTag}"
    ]
  }
}

#outputSSHCommandDecl()

<button onclick="window.location.href = 'http://www.realmethods.com/home/installation';" 
	style="font-size:0.4em;color:white;background:black">
        Get Started</button>