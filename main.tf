resource "virtualbox_vm" "node" {
  
  name      = "ubuntu-server" //format("node-%02d", count.index + 1)
  image     = "https://app.vagrantup.com/ubuntu/boxes/xenial64/versions/20211001.0.0/providers/virtualbox.box"
  cpus      = 2
  memory    = "6.0 gib"

  provisioner "remote-exec" {

    inline = ["sudo apt-get update -y", "sudo apt install python-pip -y", "sudo add-apt-repository --yes --update ppa:ansible/ansible", 
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

data "template_file" "dev_hosts" {
  template = "${file("${path.module}/ansible/hosts.yml")}"
  depends_on = [
    virtualbox_vm.node
  ]
  vars = {
    IP   = "${virtualbox_vm.node.network_adapter[0].ipv4_address}"
    USER = "vagrant"
    PK   = var.vag_pvt_key
  }
}

resource "null_resource" "dev-hosts" {
  triggers = {
    template_rendered = "${data.template_file.dev_hosts.rendered}"
  }
  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command = "echo '${data.template_file.dev_hosts.rendered}' > ./templates/dev_hosts.cfg && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook dkb-playbook.yml -u vagrant -i ./templates/dev_hosts.cfg --private-key ${var.vag_pvt_key} -e 'pub_key=.${var.vag_pub_key}'" //${var.playbook}
  }
}

output "Virtualbox_ip_addresses" {
  value = virtualbox_vm.node.network_adapter[0].ipv4_address
}

