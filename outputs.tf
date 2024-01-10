output "websiteendpoint" {
  value = aws_s3_bucket.example_bucket
}

output "public_ip" {
  value = aws_instance.thsre.public_ip
}