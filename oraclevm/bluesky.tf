# Software installation within WebServer Instance
resource "null_resource" "bigtappWebserver1HTTPD" {
  depends_on = [oci_core_instance.bigtappWebserver1]
  triggers = {
    instance_id = oci_core_instance.bigtappWebserver1.id
  }  
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      host        = data.oci_core_vnic.bigtappWebserver1_VNIC1.public_ip_address
      agent       = true
      timeout     = "10m"
    }
    inline = [
        #   Install bluesky
      "curl https://raw.githubusercontent.com/bluesky-social/pds/main/installer.sh >installer.sh",
      "sudo bash installer.sh"
    ]
  }
}
