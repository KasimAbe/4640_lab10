output "instance_ip" {
	description = "IP address of EC2 instance"
	value = aws_instance.web.public_ip
}

output "instance_dns_name" {
	description = "DNS name of EC2 instance"
	value = aws_instance.web.public_dns
}

output "instance_id" {
	description = "ID of EC2 instance"
	value = aws_instance.web.id
} 
