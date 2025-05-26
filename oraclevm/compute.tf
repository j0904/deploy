# WebServer Compute

resource "oci_core_instance" "bigtappWebserver1" {
  availability_domain        = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = oci_identity_compartment.bigtappCompartment.id
  display_name        = "bigtappWebServer"
  shape               = var.Shape

    shape_config {
    ocpus         = 1
    memory_in_gbs = 1
  }
 
  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.OSImage.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.bigtappWebSubnet.id
    assign_public_ip = true
  }
}
