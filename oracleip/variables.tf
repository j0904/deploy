variable "tenancy_ocid" {
  description = "OCID of your tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID of the user calling the API"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint for the key pair"
  type        = string
}

variable "private_key_path" {
  description = "Path to the private key file"
  type        = string
}

variable "region" {
  description = "OCI region"
  type        = string
  default     = "eu-frankfurt-1"
}

variable "compartment_ocid" {
  description = "OCID of the compartment"
  type        = string
}
