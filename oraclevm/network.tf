# VCN
resource "oci_core_virtual_network" "bigtappVCN" {
  cidr_block     = var.VCN-CIDR
  dns_label      = "bigtappVCN"
  compartment_id = oci_identity_compartment.bigtappCompartment.id
  display_name   = "bigtappVCN"
}

# DHCP Options
resource "oci_core_dhcp_options" "bigtappDhcpOptions1" {
  compartment_id = oci_identity_compartment.bigtappCompartment.id
  vcn_id         = oci_core_virtual_network.bigtappVCN.id
  display_name   = "bigtappDHCPOptions1"

  options {
    type        = "DomainNameServer"
    server_type = "VcnLocalPlusInternet"
  }

  options {
    type                = "SearchDomain"
    search_domain_names = ["bigtapp.com"]
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "bigtappInternetGateway" {
  compartment_id = oci_identity_compartment.bigtappCompartment.id
  display_name   = "bigtappInternetGateway"
  vcn_id         = oci_core_virtual_network.bigtappVCN.id
}

# Route Table
resource "oci_core_route_table" "bigtappRouteTableViaIGW" {
  compartment_id = oci_identity_compartment.bigtappCompartment.id
  vcn_id         = oci_core_virtual_network.bigtappVCN.id
  display_name   = "bigtappRouteTableViaIGW"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.bigtappInternetGateway.id
  }
}

# Security List
resource "oci_core_security_list" "bigtappSecurityList" {
  compartment_id = oci_identity_compartment.bigtappCompartment.id
  display_name   = "bigtappSecurityList"
  vcn_id         = oci_core_virtual_network.bigtappVCN.id

  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  dynamic "ingress_security_rules" {
    for_each = var.service_ports
    content {
      protocol = "6"
      source   = "0.0.0.0/0"
      tcp_options {
        max = ingress_security_rules.value
        min = ingress_security_rules.value
      }
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = var.VCN-CIDR
  }
}

# Subnet
resource "oci_core_subnet" "bigtappWebSubnet" {
  cidr_block        = var.Subnet-CIDR
  display_name      = "bigtappWebSubnet"
  dns_label         = "bigtappN1"
  compartment_id    = oci_identity_compartment.bigtappCompartment.id
  vcn_id            = oci_core_virtual_network.bigtappVCN.id
  route_table_id    = oci_core_route_table.bigtappRouteTableViaIGW.id
  dhcp_options_id   = oci_core_dhcp_options.bigtappDhcpOptions1.id
  security_list_ids = [oci_core_security_list.bigtappSecurityList.id]
}
