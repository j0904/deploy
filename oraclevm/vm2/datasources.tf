# Home Region Subscription DataSource
data "oci_identity_region_subscriptions" "home_region_subscriptions" {
  tenancy_id = var.tenancy_ocid

  filter {
    name   = "is_home_region"
    values = [true]
  }
}

# ADs DataSource
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# Images DataSource
data "oci_core_images" "OSImage" {
  compartment_id           = var.compartment_ocid
  operating_system         = var.instance_os
  operating_system_version = var.linux_os_version
  shape                    = var.Shape

   
}

# Compute VNIC Attachment DataSource
data "oci_core_vnic_attachments" "bigt2Webserver1_VNIC1_attach" {
  availability_domain = var.availability_domain_name == "" ? lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name") : var.availability_domain_name
  compartment_id      = oci_identity_compartment.bigt2Compartment.id
  instance_id         = oci_core_instance.bigt2Webserver1.id
}

# Compute VNIC DataSource
data "oci_core_vnic" "bigt2Webserver1_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.bigt2Webserver1_VNIC1_attach.vnic_attachments.0.vnic_id
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid  # or var.compartment_ocid if using a different compartment
}
