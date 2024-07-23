resource "aws_key_pair" "surya_keypair" {
  key_name   = "surya_keypair"
  public_key = file("key.pub")
}