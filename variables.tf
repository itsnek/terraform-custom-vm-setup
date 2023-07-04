
variable "username" {
    type=string
    default="nikos"
}

variable "password" {
    type=string
    default="1234"
}

variable "playbook" {
    type = string
    default = "./ansible-playbooks/docker-playbook.yml"
}

variable "vag_pvt_key" {
    type=string
    default = "./keys/vagrant/vagrant.ppk"
}

variable "vag_pub_key" {
    type=string
    default = "./keys/vagrant/vagrant.pub"
}
