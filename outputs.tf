output "websiteendpoint" {
  value = aws_s3_bucket.mybucket.id
}

output "public_ip" {
  value = aws_instance.thsre.public_ip
}