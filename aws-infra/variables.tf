variable "region" {
  description = "The region in which to provision resources."
  type        = string
  default     = "us-west-2"
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance."
  type        = string
  default     = "ami-03fc394d884ee7d48" // Ubuntu Server 20.04 LTS
}
