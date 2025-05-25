variable "compartment_ocid" {
  description = "The OCID of the compartment where the VCN will be created."
  type        = string
}

variable "vcn_cidr" {
  description = "The CIDR block for the VCN."
  type        = string
  default     = "10.0.0.0/16"
}

variable "vcn_display_name" {
  description = "The display name for the VCN."
  type        = string
  default     = "my-vcn"
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_display_name" {
  description = "The display name for the subnet."
  type        = string
  default     = "my-subnet"
}
