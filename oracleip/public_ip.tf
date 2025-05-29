resource "oci_core_public_ip" "persistent_public_ip" {
  compartment_id = var.compartment_ocid
  lifetime       = "RESERVED"
  display_name   = "persistent-public-ip"
}
