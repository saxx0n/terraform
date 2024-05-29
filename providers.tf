provider "dns" {
  update {
    server        = "dns-node1.example.com"
    key_name      = "rndc-key."
    key_algorithm = "hmac-sha256"
    key_secret    = "CHANGEME"
  }
}

provider "vsphere" {
  user                 = "terraform@vsphere.local"
  password             = "CHANGEME"
  vsphere_server       = "vcenter.example.com"
  allow_unverified_ssl = false
}