# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}

# VPC 1
resource "aws_vpc" "vpc1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "TF-VPC1"
  }
}

resource "aws_subnet" "pubsub1" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "TF-Pubsub1"
  }
}

resource "aws_internet_gateway" "tigw1" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "TF-IGW1"
  }
}


resource "aws_route_table" "pubrt1" {
  vpc_id = aws_vpc.vpc1.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.tigw1.id
    }

  tags = {
    Name = "TF-Pubrt1"
  }
}

resource "aws_route_table_association" "pubassociation1" {
  subnet_id      = aws_subnet.pubsub1.id
  route_table_id = aws_route_table.pubrt1.id
}

resource "aws_subnet" "pvtsub1" {
  vpc_id     = aws_vpc.vpc1.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "TF-Pvtsub1"
  }
}

resource "aws_eip" "teip1" {
  domain      = "vpc"
}

resource "aws_nat_gateway" "tnat1" {
  allocation_id = aws_eip.teip1.id
  subnet_id     = aws_subnet.pubsub1.id

  tags = {
    Name = "gw NAT1"
  }
}

resource "aws_route_table" "pvtrt1" {
  vpc_id = aws_vpc.vpc1.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.tnat1.id
    }

  tags = {
    Name = "TF-Pvtrt1"
  }
}

resource "aws_route_table_association" "pvtassociation1" {
  subnet_id      = aws_subnet.pvtsub1.id
  route_table_id = aws_route_table.pvtrt1.id
}

resource "aws_security_group" "allow_all" {
  name        = "Allow-all"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc1.id

  ingress {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
    
   
  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "TF-SG1"
  }
}

resource "aws_instance" "pubec2-vpc1" {
    ami                         = "ami-07b36ea9852e986ad"
    instance_type               = "t2.micro" 
    key_name                    = "lokesh"
    associate_public_ip_address = true
    availability_zone           =  "us-east-2a"
    vpc_security_group_ids      = [aws_security_group.allow_all.id]
    subnet_id                   = aws_subnet.pubsub1.id
    tags = {
        Name = "Pubec2-InstanceInVPC1"
  }
}

resource "aws_instance" "pvtec2-vpc1" {
    ami           = "ami-07b36ea9852e986ad"
    instance_type = "t2.micro" 
    key_name      = "lokesh"
    associate_public_ip_address = false
    availability_zone           =  "us-east-2b"
    vpc_security_group_ids      = [aws_security_group.allow_all.id]
    subnet_id                   = aws_subnet.pvtsub1.id
     tags = {
            Name = "Pvtec2-InstanceInVPC1"
  }
}

#################################
# VPC 2 Definitions
#################################

# VPC 2
resource "aws_vpc" "vpc2" {
  cidr_block       = "172.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "TF-VPC2"
  }
}

resource "aws_subnet" "pubsub2" {
  vpc_id            = aws_vpc.vpc2.id
  cidr_block        = "172.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "TF-Pubsub2"
  }
}

resource "aws_internet_gateway" "tigw2" {
  vpc_id = aws_vpc.vpc2.id

  tags = {
    Name = "TF-IGW2"
  }
}

resource "aws_route_table" "pubrt2" {
  vpc_id = aws_vpc.vpc2.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.tigw2.id
    }

  tags = {
    Name = "TF-Pubrt2"
  }
}

resource "aws_route_table_association" "pubassociation2" {
  subnet_id      = aws_subnet.pubsub2.id
  route_table_id = aws_route_table.pubrt2.id
}

resource "aws_subnet" "pvtsub2" {
  vpc_id     = aws_vpc.vpc2.id
  cidr_block = "172.0.2.0/24"
  availability_zone = "us-east-2b"

  tags = {
    Name = "TF-Pvtsub2"
  }
}

resource "aws_eip" "teip2" {
  domain = "vpc"
}

resource "aws_nat_gateway" "tnat2" {
  allocation_id = aws_eip.teip2.id
  subnet_id     = aws_subnet.pubsub2.id

  tags = {
    Name = "gw NAT2"
  }
}

resource "aws_route_table" "pvtrt2" {
  vpc_id = aws_vpc.vpc2.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.tnat2.id
    }

  tags = {
    Name = "TF-Pvtrt2"
  }
}

resource "aws_route_table_association" "pvtassociation2" {
  subnet_id      = aws_subnet.pvtsub2.id
  route_table_id = aws_route_table.pvtrt2.id
}

resource "aws_security_group" "allow_all2" {
  name        = "Allow-all"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.vpc2.id

  ingress {
      description      = "SSH from VPC"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
    
  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
    }

  tags = {
    Name = "TF-SG2"
  }
}

resource "aws_instance" "pubec2-vpc2" {
    ami                         = "ami-07b36ea9852e986ad"
    instance_type               = "t2.micro" 
    key_name                    = "lokesh"
    associate_public_ip_address = true
    availability_zone           =  "us-east-2a"
    vpc_security_group_ids      = [aws_security_group.allow_all2.id]
    subnet_id                   = aws_subnet.pubsub2.id
     tags = {
            Name = "Pubec2-InstanceInVPC2"
  }
}

resource "aws_instance" "pvtec2-vpc2" {
    ami           = "ami-07b36ea9852e986ad"
    instance_type = "t2.micro" 
    key_name      = "lokesh"
    associate_public_ip_address = false
    availability_zone           =  "us-east-2b"
    vpc_security_group_ids      = [aws_security_group.allow_all2.id]
    subnet_id                   = aws_subnet.pvtsub2.id
     tags = {
            Name = "Pvtec2-InstanceInVPC2"
  }
}

# VPC Peering from VPC1 to VPC2
resource "aws_vpc_peering_connection" "peering_vpc1_to_vpc2" {
  vpc_id            = aws_vpc.vpc1.id
  peer_vpc_id       = aws_vpc.vpc2.id
  peer_owner_id     = data.aws_caller_identity.current.account_id
  peer_region       = "us-east-2" # Specify the correct region for the peer VPC
  auto_accept       = true
  tags = {
    Name = "VPC1-to-VPC2-Peering"
  }
}
 
# Route traffic destined for VPC2's CIDR block through the VPC peering connection in VPC1
resource "aws_route" "peer_route_vpc2" {
  route_table_id            = aws_route_table.pvtrt1.id
  destination_cidr_block    = aws_vpc.vpc2.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_vpc1_to_vpc2.id
}

# Route traffic destined for VPC1's CIDR block through the VPC peering connection in VPC2
resource "aws_route" "peer_route_vpc1" {
  route_table_id            = aws_route_table.pvtrt2.id
  destination_cidr_block    = aws_vpc.vpc1.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering_vpc1_to_vpc2.id
}



# Data source to get current account ID
data "aws_caller_identity" "current" {}
