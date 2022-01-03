data "aws_ssm_parameter" "linuxAmi" {
  provider = aws.region-master
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

data "aws_ssm_parameter" "linuxAmiOregon" {
  provider = aws.region-worker
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# Create Key-pair for logging into EC2  in us-east-1
resource "aws_key_pair" "master-key" {
  provider   = aws.region-master
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}
# Create Key-pair for logging into EC2 in us-west-2
resource "aws_key_pair" "worker-key" {
  provider   = aws.region-worker
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}


/*
resource "tls_private_key" "ec2instance" {
  algorithm = "RSA"
}

resource "aws_key_pair" "instance" {
  key_name = "lamp"
  //public_key = tls_private_key.ec2instance.public_key_pem
  public_key = tls_private_key.ec2instance.public_key_openssh
  //public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7v8uZI88Qc7v+10gSw9TszybIpYVsT4p8cC5ghgNUf/fAIdPcuHazV/+SRrsa+Dk8MW0jWgBV4oLuWDqhEk/Es35iM5HC1yZ9qHrdwUPRLO7EUEtsU8MImRiUoSTouaS69KWEJE65i9HS7yI/kfOgq/tWnpL2llYbuV+11EsNa51Ic8jw56JGGB8lu30ji7LRtVtT3rp7v+Wreh0vyOXtf5uzrqBnnFebvmUcdD128NMGvD6rwUvG+F8OHBwYqsToYPJv6JWULUqCPinbl28dnvr8Uzot1VnyZNvLwc+W4Tt2Sp+LeWNX+Cagl4MPvqLod5LVnNI+Np/gr+KKyXYzRjZ47gqwRJWec6avXuY+b6bL+Xp6k8b36BJ0aquf75Slw3pEmmNNeYEmGBGHM3EAGCuQG9wtScp2nF2DqXhgb2rw0K4m12Eyao4sb4pkeycz8y8igZzdeYl1moB5uPePbRGT39htlV/NVx9AclZ5xBImSC2cev0ZZeVuPDSjXoc="
}
*/