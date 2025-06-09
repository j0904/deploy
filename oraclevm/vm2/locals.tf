# Dictionary Locals
locals { 
  default_availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name", "")
}
