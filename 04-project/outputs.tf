output "bastion_public_ip" {
  value = aws_instance.vapp-bastion.public_ip
}
