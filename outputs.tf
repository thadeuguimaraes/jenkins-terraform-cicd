output "websiteendpoint" {
  value = aws_s3_bucket.mybucket
}

output "public_ip" {
  value = aws_instance.thsre.public_ip
}