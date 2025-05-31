variable "location" {
  description = "The Azure region to deploy resources"
  default     = "East Asia" # Hong Kong region
}

variable "vm_size" {
  description = "Free tier eligible VM size"
  default     = "Standard_B1s" # 1 vCPU, 1GB RAM (750 free hours/month)
}

variable "admin_username" {
  description = "Admin username for the VM"
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  default     = "/home/jcui/.ssh/id_rsa.pub" # Default path to public key
}
