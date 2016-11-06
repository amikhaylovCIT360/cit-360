# Add your VPC ID to default below
variable "vpc_id" {
  description = "The VPC number"
  default = "vpc-149a6973"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_subnet" "public_subnet_us_west_2a" {
	vpc_id = "${var.vpc_id}"
	cidr_block = "172.31.12.0/24"
	map_public_ip_on_launch = true
	availability_zone = "us-west-2a"
	tags = {
		Name = "Public Subnet 2a"
	}
}

resource "aws_subnet" "public_subnet_us_west_2b" {
	vpc_id = "${var.vpc_id}"
	cidr_block = "172.31.13.0/24"
	map_public_ip_on_launch = true
	availability_zone = "us-west-2b"
	tags = {
		Name = "Public Subnet 2b"
	}
}

resource "aws_subnet" "public_subnet_us_west_2c" {
	vpc_id = "${var.vpc_id}"
	cidr_block = "172.31.14.0/24"
	map_public_ip_on_launch = true
	availability_zone = "us-west-2c"
	tags = {
		Name = "Public Subnet 2c"
	}
}

resource "aws_subnet" "private_subnet_us_west_2a" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "172.31.0.0/22"
  availability_zone = "us-west-2a"
  tags = {
  	Name =  "Private Subnet 1a"
  }
}

resource "aws_subnet" "private_subnet_us_west_2b" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "172.31.4.0/22"
  availability_zone = "us-west-2b"
  tags = {
  	Name =  "Private Subnet 2b"
  }
}

resource "aws_subnet" "private_subnet_us_west_2c" {
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "172.31.8.0/22"
  availability_zone = "us-west-2c"
  tags = {
  	Name =  "Private Subnet 2c"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${var.vpc_id}"

  tags = {
    Name = "gw"
  }
}


resource "aws_route_table" "public_route_table" {
	vpc_id = "${var.vpc_id}"

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_internet_gateway.gw.id}"
	}

	tags = {
		Name = "public route table"
	}
}


resource "aws_eip" "cit_eip" {
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.cit_eip.id}"
    subnet_id = "${aws_subnet.public_subnet_us_west_2a.id}"
    depends_on = ["aws_internet_gateway.gw"]
}

resource "aws_route_table" "private_route_table" {
    vpc_id = "${var.vpc_id}"
 	
 	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = "${aws_nat_gateway.nat.id}"
	}

    tags {
        Name = "Private route table"
    }
}

resource "aws_route_table_association" "public_subnet_us_west_2a_association" {
    subnet_id = "${aws_subnet.public_subnet_us_west_2a.id}"
    route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "public_subnet_us_west_2b_association" {
    subnet_id = "${aws_subnet.public_subnet_us_west_2b.id}"
    route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "public_subnet_us_west_2c_association" {
    subnet_id = "${aws_subnet.public_subnet_us_west_2c.id}"
    route_table_id = "${aws_route_table.public_route_table.id}"
}

resource "aws_route_table_association" "private_subnet_us_west_2a_association" {
    subnet_id = "${aws_subnet.private_subnet_us_west_2a.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_route_table_association" "private_subnet_us_west_2b_association" {
    subnet_id = "${aws_subnet.private_subnet_us_west_2b.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_route_table_association" "private_subnet_us_west_2c_association" {
    subnet_id = "${aws_subnet.private_subnet_us_west_2c.id}"
    route_table_id = "${aws_route_table.private_route_table.id}"
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  description = "Allow all inbound ssh traffic"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_instance" "web" {
    ami = "ami-5ec1673e"
    instance_type = "t2.micro"
    vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
    subnet_id = "${aws_subnet.public_subnet_us_west_2a.id}"
    associate_public_ip_address = true
    key_name = "cit360"

    tags {
        Name = "HelloWorld"
    }
}



