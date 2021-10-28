terraform {
  backend "s3" {
    bucket = "forterraform1"
    key = "ntier/ntier_state"
    region = "ap-south-1"
    dynamodb_table = "forterraform"

  }
}