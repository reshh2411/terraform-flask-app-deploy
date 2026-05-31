provider "aws" {
  region = "eu-north-1"
}

resource "aws_key_pair" "example" {
  key_name   = "terraform-demo-reshma" 
  public_key = file("C:\\Users\\RESHMA\\.ssh\\id_rsa.pub")
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create a public subnet in the VPC
resource "aws_subnet" "my_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "eu-north-1a"
  map_public_ip_on_launch = true
}

# Create an Internet Gateway and attach it to the VPC to make the subnet public
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a route table and add a route to the Internet Gateway for internet access
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}

# Associate the route table with the subnet to enable internet access
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.my_vpc.id

  ingress { #inbound rules
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { #outbound rules
    description = "outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }
}

# store terraform state in the S3 bucket defined in backend.tf
resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = "reshma-terraform-state-s3" #same name as in backend.tf
}

resource "aws_instance" "server" {
    ami = "ami-05d62b9bc5a6ca605"
    instance_type = "t3.micro"
    key_name = aws_key_pair.example.key_name
    subnet_id = aws_subnet.my_subnet.id
    vpc_security_group_ids = [aws_security_group.webSg.id]

    connection {
        type = "ssh"
        user = "ubuntu"
        host = self.public_ip
        private_key = file("C:\\Users\\RESHMA\\.ssh\\id_rsa")
    }

    provisioner "file" {
        source      = "app.py"  
        destination = "/home/ubuntu/app.py"  
    }

    provisioner "remote-exec" {
        inline = [
        "echo 'Hello from the remote instance'",
        "sudo apt update -y",  # Update package lists (for ubuntu)
        "sudo apt-get install -y python3-pip",  # Example package installation
        "cd /home/ubuntu",
        "sudo pip3 install flask",
        "sudo python3 app.py &",
    ]
  }
}
