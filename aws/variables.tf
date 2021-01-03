variable "public_key_path" {
  description = "ssh .pub key path. loaded from tfvars file"
}

variable "key_name" {
  description = "Desired name of AWS key pair. loaded from tfvars file"
}

#Here to ensure people can ssh | we'll do test install of nginx
variable "secret_key" {
  description = "private key to login. loaded from tfvars file"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "ap-south-1"
}

variable "aws_zone" {
  description = "machine type/shape verified"
  default = "ap-south-1a"
}

# Ubuntu Server 20.04 LTS (x64 x86)
variable "aws_amis" {
  default = "ami-0a4a70bd98c6d6441"
}
