resource "virtualbox_vm" "node" {
  
  count     = 1
  name      = "ubuntu-server" //format("node-%02d", count.index + 1)
  image     = "https://app.vagrantup.com/ubuntu/boxes/xenial64/versions/20211001.0.0/providers/virtualbox.box"
  cpus      = 2
  memory    = "6144 mib"

  # Copy in the bash script we want to execute.
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook create-users.yml dkb-playbook.yml -u vagrant -i '${self.network_adapter[0].ipv4_address},' --private-key ${var.vag_pvt_key} -e 'pub_key=.${var.vag_pub_key}'" //${var.playbook}
  }

  provisioner "remote-exec" {

    inline = ["sudo apt-get update", "sudo apt install python-pip -y", "sudo add-apt-repository --yes --update ppa:ansible/ansible", 
    "sudo apt-get install ansible -y"]

    connection {
      host        = "${self.network_adapter[0].ipv4_address}"
      user        = "vagrant"
      password    = "vagrant"
      type        = "ssh"
      private_key = file(var.vag_pvt_key)
    }

  }

  network_adapter {
    type           = "bridged"
    host_interface = "enp42s0"
  }

}

output "Virtualbox_ip_addresses" {
  value = {
    for node in virtualbox_vm.node:
    node.name => node.network_adapter[0].ipv4_address
  }
}

