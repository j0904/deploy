# Software installation within WebServer Instance
resource "null_resource" "bluesky" {
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
        # 1. Install 
      "sudo curl https://raw.githubusercontent.com/j0904/deploy/main/bluesky/installer.sh >installer.sh",

      # 2. #
      "sudo bash installer.sh  " ,
 
    ]
  }
}
