resource "oci_identity_compartment" "bigtappCompartment" {
  provider = oci.homeregion
  name = "bigtappCompartment"
  description = "bigtapp Compartment"
  compartment_id = var.compartment_ocid

  provisioner "local-exec" {
    command = "sleep 60"
  }
}
