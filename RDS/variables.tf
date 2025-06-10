variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "private_server_sg_id" {
  type = string
}

variable "backend_subnet_az_1a" {
  type = string
}

variable "backend_subnet_az_1b" {
  type = string
}

variable "parameter_group_name" {
  type = string
}

variable "allocated_storage" {
  type = string
}

variable "instance_class" {
  type = string
}

variable "engine_version" {
  type = string
}