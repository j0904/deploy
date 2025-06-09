resource "oci_identity_compartment" "bigtappCompartment" {
  provider = oci.homeregion
  name = "bigtappCompartment"
  description = "bigtapp Compartment"
  compartment_id = var.compartment_ocid

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "oci_identity_compartment" "bigt2Compartment" {
  name        = "bigt2-compartment"
  description = "Compartment for bigt2 resources"
  enable_delete = true
  compartment_id = var.tenancy_ocid
}
