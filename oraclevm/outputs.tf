# WebServer Instance Public IP
output "bigtappWebserver1PublicIP" {
  value = [data.oci_core_vnic.bigtappWebserver1_VNIC1.public_ip_address]
}
