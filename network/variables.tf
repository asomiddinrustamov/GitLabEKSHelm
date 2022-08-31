variable "region" {
  type = string
}

variable "az" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "vpc_cidr_block" {
  type = string
}

variable "private_network_config" {
  type = map(object({
    cidr_block               = string
    associated_public_subnet = string
  }))

  default = {
    "private-devops-1" = {
      cidr_block               = "10.0.0.0/23"
      associated_public_subnet = "public-devops-1"
    },
    "private-devops-2" = {
      cidr_block               = "10.0.2.0/23"
      associated_public_subnet = "public-devops-2"
    }
  }
}

locals {
  private_nested_config = flatten([
    for name, config in var.private_network_config : [
      {
        name                     = name
        cidr_block               = config.cidr_block
        associated_public_subnet = config.associated_public_subnet
      }
    ]
  ])
}

variable "public_network_config" {
  type = map(object({
    cidr_block = string
  }))

  default = {
    "public-devops-1" = {
      cidr_block = "10.0.8.0/23"
    },
    "public-devops-2" = {
      cidr_block = "10.0.10.0/23"
    }
  }
}

locals {
  public_nested_config = flatten([
    for name, config in var.public_network_config : [
      {
        name       = name
        cidr_block = config.cidr_block
      }
    ]
  ])
}
