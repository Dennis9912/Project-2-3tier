variable "vpc_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "alb_sg_id" {
  type = string
}

variable "image_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "public_subnet_az_1a_id" {
  type = string
}

variable "public_subnet_az_1b_id" {
  type = string
}

variable "target_group_arn" {
  type = string
}