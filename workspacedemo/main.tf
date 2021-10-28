resource "aws_vpc" "ntier" {
    cidr_block = var.ntier_cidr
    
    tags = {
        Name = "ntier-${terraform.workspace}"
    }  
}

# Depends on aws vpc

resource "aws_subnet" "subnets" {

    count = length(var.ntier_subnet_Azs)

    cidr_block = cidrsubnet(var.ntier_cidr, 8, count.index)
    availability_zone = var.ntier_subnet_Azs[count.index]
    tags = {
        Name = "${var.ntier_subnet_tags[count.index]}-${terraform.workspace}"
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
        Name = "ntierigw-${terraform.workspace}"
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
        Name = "ntier-publicrt-${terraform.workspace}"
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
        Name = "ntier-privatert-${terraform.workspace}"
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



  

