resource "aws_vpc" "ntier" {
    cidr_block = var.ntier_cidr
    
    tags = {
        Name = "ntier"
    }  
}

# Depends on aws vpc

resource "aws_subnet" "subnets" {

    count = length(var.ntier_subnet_Azs)

    cidr_block = cidrsubnet(var.ntier_cidr, 8, count.index)
    availability_zone = var.ntier_subnet_Azs[count.index]
    tags = {
        Name = var.ntier_subnet_tags[count.index]
    }
    vpc_id = aws_vpc.ntier.id 

    depends_on = [
      aws_vpc.ntier
    ]  
}

# Creating internet gatway

resource "aws_internet_gateway" "ntierigw" {
    vpc_id = aws_vpc.ntier.id

    tags = {
        Name = "ntierigw"
    }

    depends_on = [
      aws_vpc.ntier
    ]
  
}

# creating public route table

resource "aws_route_table" "publicrt" {
    vpc_id = aws_vpc.ntier.id
    route = [ ]
    tags = {
        Name = "ntier-publicrt"
    }

    depends_on = [
      aws_vpc.ntier,
      aws_subnet.subnets
    ]
  
}

resource "aws_route" "publicrt" {
    route_table_id = aws_route_table.publicrt.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ntierigw.id 
}

resource "aws_route_table_association" "publicrtassociations" {
    count = length(var.web_subnet_indexes)
    subnet_id = aws_subnet.subnets[var.web_subnet_indexes[count.index]].id 
    route_table_id = aws_route_table.publicrt.id
    depends_on = [
      aws_vpc.ntier,
      aws_subnet.subnets,
      aws_route_table.publicrt
    ]
  
}

# creating private route table

resource "aws_route_table" "privatert" {
    vpc_id = aws_vpc.ntier.id
    route = [ ]
    tags = {
        Name = "ntier-privatert"
    }

    depends_on = [
      aws_vpc.ntier,
      aws_subnet.subnets
    ]
  
}

resource "aws_route_table_association" "privatertassociations" {
    count = length(var.other_subnet_indexes)
    subnet_id = aws_subnet.subnets[var.other_subnet_indexes[count.index]].id 
    route_table_id = aws_route_table.privatert.id
    depends_on = [
      aws_vpc.ntier,
      aws_subnet.subnets,
      aws_route_table.privatert
    ]
  
}

resource "aws_security_group" "websg" {
    name = "openhttp"
    description = "Open http and ssh"
    vpc_id = aws_vpc.ntier.id

    tags = {
        Name = "Openhttp"
    }  
    depends_on = [
        aws_vpc.ntier,
        aws_subnet.subnets,
        aws_route_table.publicrt,
        aws_route_table.privatert
      
    ] 
}

resource "aws_security_group_rule" "websghttp" {
    type = "ingress"
    to_port = 80
    protocol = "TCP"
    from_port = 80
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.websg.id
  
}

resource "aws_security_group_rule" "websgssh" {
    type = "ingress"
    to_port = 22
    protocol = "TCP"
    from_port = 22
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = aws_security_group.websg.id
  
}

resource "aws_instance" "webserver" {
    count = var.enable_vm ? 1: 0
    ami = "ami-04bde106886a53080"  # ami for ubuntu 18 in mumbai region
    instance_type = "t2.micro"
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.websg.id]
    subnet_id = aws_subnet.subnets[0].id
    tags = {
      "Name" = "webserver"
    }
    depends_on = [
      aws_vpc.ntier,
      aws_subnet.subnets,
      aws_route_table.publicrt,
      aws_security_group.websg
    ]
}


  

