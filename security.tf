data "aws_route_table" "okto_public_rt" {
  vpc_id                             = aws_vpc.okto_vpc.id
  route_table_id                     = aws_vpc.okto_vpc.default_route_table_id
}

resource "aws_vpc" "okto_vpc" {
    assign_generated_ipv6_cidr_block = false
    cidr_block                       = "20.0.0.0/16"
    enable_classiclink               = false
    enable_classiclink_dns_support   = false
    enable_dns_hostnames             = true
    enable_dns_support               = true
    instance_tenancy                 = "default"
    tags                             = {
        "Name" = "okto-vpc"
    }
    tags_all                         = {
        "Name" = "okto-vpc"
    }
}

resource "aws_subnet" "okto_public_subnet_1A" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1a"
    cidr_block                      = "20.0.1.0/24"
    map_public_ip_on_launch         = true
    tags                            = {
        "Name" = "okto-public-1A"
    }
    tags_all                        = {
        "Name" = "okto-public-1A"
    }
    vpc_id                          = aws_vpc.okto_vpc.id

    timeouts {}
}

resource "aws_subnet" "okto_public_subnet_1B" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1b"
    cidr_block                      = "20.0.2.0/24"
    map_public_ip_on_launch         = true
    tags                            = {
        "Name" = "okto-public-1B"
    }
    tags_all                        = {
        "Name" = "okto-public-1B"
    }
    vpc_id                          = aws_vpc.okto_vpc.id

    timeouts {}
}

resource "aws_subnet" "okto_private_subnet_1A" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1a"
    cidr_block                      = "20.0.3.0/24"
    map_public_ip_on_launch         = false
    tags                            = {
        "Name" = "okto-private-1A"
    }
    tags_all                        = {
        "Name" = "okto-private-1A"
    }
    vpc_id                          = aws_vpc.okto_vpc.id

    timeouts {}
}

resource "aws_subnet" "okto_private_subnet_1B" {
    assign_ipv6_address_on_creation = false
    availability_zone               = "us-east-1b"
    cidr_block                      = "20.0.4.0/24"
    map_public_ip_on_launch         = false
    tags                            = {
        "Name" = "okto-private-1B"
    }
    tags_all                        = {
        "Name" = "okto-private-1B"
    }
    vpc_id                          = aws_vpc.okto_vpc.id

    timeouts {}
}

resource "aws_db_subnet_group" "okto_public_subnet_group" {
  name       = "okto_public_subnet_group"
  subnet_ids = [aws_subnet.okto_public_subnet_1A.id, aws_subnet.okto_public_subnet_1B.id]

  tags = {
    Name = "My public DB subnet group"
  }
}

resource "aws_db_subnet_group" "okto_private_subnet_group" {
  name       = "okto_private_subnet_group"
  subnet_ids = [aws_subnet.okto_private_subnet_1A.id, aws_subnet.okto_private_subnet_1B.id]

  tags = {
    Name = "My private DB subnet group"
  }
}

resource "aws_route" "igw_route" {
    route_table_id             = data.aws_route_table.okto_public_rt.id
    destination_cidr_block     = "0.0.0.0/0"
    gateway_id                 = aws_internet_gateway.okto_igw.id
}

resource "aws_route_table" "okto_private_rt" {
    propagating_vgws = []
    route            = []
    tags             = {
        "Name" = "okto-private-rtb"
    }
    tags_all         = {
        "Name" = "okto-private-rtb"
    }
    vpc_id           = aws_vpc.okto_vpc.id

    timeouts {}
}

resource "aws_route_table_association" "private_assoc_a" {
  subnet_id      = aws_subnet.okto_private_subnet_1A.id
  route_table_id = aws_route_table.okto_private_rt.id
}

resource "aws_route_table_association" "private_assoc_b" {
  subnet_id      = aws_subnet.okto_private_subnet_1B.id
  route_table_id = aws_route_table.okto_private_rt.id
}

resource "aws_internet_gateway" "okto_igw" {
    tags     = {
        "Name" = "okto-igw"
    }
    tags_all = {
        "Name" = "okto-igw"
    }
    vpc_id   = aws_vpc.okto_vpc.id
}

resource "aws_security_group" "okto_sg" {
    description = "OKTO VPC security group"
    egress      = [
        {
            cidr_blocks      = [
                "0.0.0.0/0",
            ]
            description      = ""
            from_port        = 0
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "-1"
            security_groups  = []
            self             = false
            to_port          = 0
        },
    ]
    ingress     = [
        {
            cidr_blocks      = [
                "82.208.160.88/32",
                "0.0.0.0/0",
            ]
            description      = ""
            from_port        = 0
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "tcp"
            security_groups  = []
            self             = false
            to_port          = 65535
        },
        {
            cidr_blocks      = []
            description      = ""
            from_port        = 0
            ipv6_cidr_blocks = []
            prefix_list_ids  = []
            protocol         = "-1"
            security_groups  = []
            self             = true
            to_port          = 0
        },
    ]
    name        = "okto-public-sg"
    tags        = {}
    tags_all    = {}
    vpc_id      = aws_vpc.okto_vpc.id

    timeouts {}
}