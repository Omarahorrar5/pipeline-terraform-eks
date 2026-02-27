resource "aws_vpc" "test_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "test_public_subnet" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "test_internet_gateway" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "test_public_rt" {
  vpc_id = aws_vpc.test_vpc.id

  tags = {
    Name = "dev-public-rt"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.test_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.test_internet_gateway.id
}

resource "aws_route_table_association" "test_public_assoc" {
  subnet_id      = aws_subnet.test_public_subnet.id
  route_table_id = aws_route_table.test_public_rt.id
}

resource "aws_security_group" "test_sg" {
  name        = "dev_sg"
  description = "test security group"
  vpc_id      = aws_vpc.test_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "test_auth" {
  key_name   = "testkey"
  public_key = file("~/.ssh/testkey.pub")
}


resource "aws_instance" "dev_node" {
  ami                    = data.aws_ami.server_ami.id
  instance_type          = "t3.small"
  key_name               = aws_key_pair.test_auth.id
  vpc_security_group_ids = [aws_security_group.test_sg.id]
  subnet_id              = aws_subnet.test_public_subnet.id

  tags = {
    Name = "dev-node"
  }
}