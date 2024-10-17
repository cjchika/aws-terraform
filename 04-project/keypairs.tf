resource "aws_key_pair" "vappkey" {
  key_name   = "vappkey"
  public_key = file(var.PUB_KEY_PATH)
}
