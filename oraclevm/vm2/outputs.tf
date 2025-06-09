# WebServer Instance Public IP
output "bigt2Webserver1PublicIP" {
  value = [data.oci_core_vnic.bigt2Webserver1_VNIC1.public_ip_address]
}
