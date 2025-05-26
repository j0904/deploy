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
        # 1. Install iptables-persistent (non-interactively)
      "sudo DEBIAN_FRONTEND=noninteractive apt-get install -y iptables-persistent",

      # 2. Backup existing rules
      "sudo cp /etc/iptables/rules.v4 /etc/iptables/rules.v4.bak",

      # 3. Allow HTTP/HTTPS in iptables
      <<-EOT
      sudo bash -c 'cat > /etc/iptables/rules.v4 <<EOF
      *filter
      :INPUT ACCEPT [0:0]
      :FORWARD ACCEPT [0:0]
      :OUTPUT ACCEPT [0:0]
      -A INPUT -i lo -j ACCEPT
      -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
      -A INPUT -p icmp -j ACCEPT
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 22 -j ACCEPT
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
      -A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT
      -A INPUT -j DROP
      COMMIT
      EOF'
      EOT
      ,

      # 4. Apply the new rules
      "sudo iptables-restore < /etc/iptables/rules.v4",
      "sudo netfilter-persistent save",
 
    ]
  }
}
