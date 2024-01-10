terraform {
  backend "s3" {
    bucket         = "thsrematrix"
    key            = "my-terraform-environment/main"
    region         = "us-east-1"
    dynamodb_table = "matrix-dynamo-db-table"
  }
}