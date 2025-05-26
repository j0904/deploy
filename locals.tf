# Dictionary Locals
locals {
  compute_flexible_shapes = [
"VM.Standard.E2.1.Micro"
   
  ]
  is_flexible_shape = contains(local.compute_flexible_shapes, var.Shape)
  default_availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[0], "name", "")
}
