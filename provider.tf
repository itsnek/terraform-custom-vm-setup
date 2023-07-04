terraform {
  required_providers {
    virtualbox = {
      source   = "terra-farm/virtualbox"
      version  = "0.2.2-alpha.1"
    }
  }
}

provider "virtualbox" {
  # There are currently no configuration options for the provider itself.
}
