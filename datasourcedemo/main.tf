data "aws_vpc" "default" {
    cidr_block = "172.31.0.0/16"
}

output "defaultvpcid" {
    value = data.aws_vpc.default
  
}