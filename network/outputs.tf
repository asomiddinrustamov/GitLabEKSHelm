output "nat1_ip" {
    value = aws_eip.nat["public-devops-1"].public_ip
}

output "nat2_ip" {
    value = aws_eip.nat["public-devops-2"].public_ip
}