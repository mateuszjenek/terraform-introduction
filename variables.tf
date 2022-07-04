variable "name" {
  type = string
  description = "Unique name of created infrastucture"
}

variable "owner" {
  type = string
  description = "UUID of employee responsible for the infrastructure"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}