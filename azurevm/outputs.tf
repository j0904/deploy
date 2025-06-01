output "vm_public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}

output "admin_username" {
  value = var.admin_username
}

output "ssh_command" {
  value = "ssh ${var.admin_username}@${azurerm_public_ip.public_ip.ip_address}"
}

output "bsky_public_ip_address" {
  value       = azurerm_public_ip.bsky_public_ip.ip_address
  description = "The public IP address of the bsky VM."
}
