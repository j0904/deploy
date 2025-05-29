output "persistent_public_ip" {
  value = oci_core_public_ip.persistent_public_ip.ip_address
}
