variable "vpc_cidr_block" {
  type = string
}

variable "public_cidr_block" {
  type = list(string)
}

variable "private_cidr_block" {
  type = list(string)
}

variable "availability_zone" {
  type = list(string)
}

variable "acm_certificate_arn" {
  type = string
}

variable "ssl_policy" {
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

variable "zone_id" {
  type = string
}

variable "domain_name" {
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