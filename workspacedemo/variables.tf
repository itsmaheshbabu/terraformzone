variable "ntier_cidr" {
    type = string
    default = "10.10.0.0/16"
}

variable "ntier_region" {
    type = string
    default = "ap-south-1"  
}

variable "ntier_subnet_Azs" {
    type = list(string)
    default = [ "ap-south-1a", "ap-south-1b", "ap-south-1c", "ap-south-1a", "ap-south-1b", "ap-south-1c" ]
}

 variable "ntier_subnet_tags" {
    default = ["ntier-web1", "ntier-app1", "ntier-db1", "ntier-web2", "ntier-app2", "ntier-db2"]
}

variable "web_subnet_indexes" {
    type = list(number)
    default = [ 0 ]  
}

variable "other_subnet_indexes" {
    type = list(number)
    default = [ 1,2]
  
}

