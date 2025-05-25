output "vcn_id" {
  description = "The OCID of the created VCN."
  value       = oci_core_vcn.vcn.id
}

output "vcn_name" {
  description = "The display name of the created VCN."
  value       = oci_core_vcn.vcn.display_name
}

output "subnet_id" {
  description = "The OCID of the created subnet."
  value       = oci_core_subnet.subnet.id
}

output "subnet_name" {
  description = "The display name of the created subnet."
  value       = oci_core_subnet.subnet.display_name
}
