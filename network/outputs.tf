output "nat1_ip" {
  value = aws_eip.nat["public-devops-1"].public_ip
}

output "nat2_ip" {
  value = aws_eip.nat["public-devops-2"].public_ip
}

output "vpc_id" {
  value = aws_vpc.devops.id
}

output "eip_nat" {
  value = aws_eip.nat
}

output "subnet_private" {
  value = aws_subnet.private
}

output "subnet_public" {
  value = aws_subnet.public
}