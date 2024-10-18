resource "aws_instance" "vapp-bastion" {
  ami                         = lookup(var.AMIS, var.AWS_REGION)
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.vappkey.key_name
  subnet_id                   = module.vpc.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.vapp-bation-sg.id]
  associate_public_ip_address = true

  tags = {
    Name      = "vapp-bastion"
    Project   = "vapp"
    ManagedBy = "Terraform"
  }

  provisioner "file" {
    connection {
      user        = var.USERNAME
      private_key = file(var.PRIV_KEY_PATH)
      host        = self.public_ip
    }

    content     = templatefile("templates/db-deploy.tmpl", { rds-endpoint = aws_db_instance.vapp-rds.address, dbuser = var.dbuser, dbpass = var.dbpass })
    destination = "/tmp/vapp-dbdeploy.sh"
  }

  provisioner "remote-exec" {
    connection {
      user        = var.USERNAME
      private_key = file(var.PRIV_KEY_PATH)
      host        = self.public_ip
    }

    inline = [
      "chmod +x /tmp/vapp-dbdeploy.sh",
      "sudo /tmp/vapp-dbdeploy.sh"
    ]
  }

  depends_on = [aws_db_instance.vapp-rds]
}
