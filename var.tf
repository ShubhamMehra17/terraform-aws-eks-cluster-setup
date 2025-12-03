variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "cluster_name" {
  type    = string
  default = "prod-eks"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["ap-south-1a","ap-south-1b","ap-south-1c"]
}

variable "public_subnet_cidrs" {
  type = list(string)
  default = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
}

variable "private_subnet_cidrs" {
  type = list(string)
  default = ["10.0.64.0/19", "10.0.96.0/19", "10.0.128.0/19"]
}

variable "admin_cidr" {
  type    = string
  description = "Your admin IP/CIDR for kubectl/ssh access"
  default = "157.49.47.125/32"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_desired" { 
  type = number 
  default = 2 
}

variable "node_min" { 
  type = number
  default = 2 
}

variable "node_max" { 
  type = number
  default = 4 
}

