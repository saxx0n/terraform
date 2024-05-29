locals {
  ansible_args = "-u ansible --private-key ~/.ssh/id_rsa_ansible --become-pass-file .password --ssh-common-args='-o StrictHostKeyChecking=no'"
  domain       = "example.com"
  dns          = ["10.0.105.21", "10.0.105.22"]
}

variable "mac_addr" {
  type = map(string)
  default = {
    aap-ctrl  = "00:50:56:8d:aa:aa"
    aap-work1 = "00:50:56:8d:aa:ab"
    aap-work2 = "00:50:56:8d:aa:ac"
    bitwarden = "00:50:56:8d:aa:ad"
    builder   = "00:50:56:8d:aa:ae"
    codecov   = "00:50:56:8d:aa:af"
    dns1      = "00:50:56:8d:aa:ba"
    dns2      = "00:50:56:8d:aa:bb"
    eebuilder = "00:50:56:8d:aa:bc"
    gitlab    = "00:50:56:8d:aa:bd"
    k3s-node1 = "00:50:56:8d:aa:be"
    k3s-node2 = "00:50:56:8d:aa:bf"
    k3s-node3 = "00:50:56:8d:aa:ca"
    mailsrv   = "00:50:56:8d:aa:cb"
    pihole1   = "00:50:56:8d:aa:ce"
    pihole2   = "00:50:56:8d:aa:cf"
    proxy     = "00:50:56:8d:aa:da"
    runner1   = "00:50:56:8d:aa:db"
    runner2   = "00:50:56:8d:aa:de"
    runner3   = "00:50:56:8d:aa:df"
    vault     = "00:50:56:8d:aa:ea"
    wireguard = "00:50:56:8d:aa:eb"
  }
}

variable "netmask" {
  type = map(string)
  default = {
    dmz        = "24"
    k8s        = "24"
    monitoring = "24"
    servers    = "23"
    vpn        = "28"
  }
}

variable "gateway" {
  type = map(string)
  default = {
    dmz        = "10.0.185.1"
    k8s        = "10.0.135.1"
    monitoring = "10.0.145.1"
    servers    = "10.0.105.1"
    vpn        = "10.0.95.1"
  }
}

variable "ip_addr" {
  type = map(string)
  default = {
    aap-ctrl  = "10.0.145.101"
    aap-work1 = "10.0.145.111"
    aap-work2 = "10.0.145.112"
    bitwarden = "10.0.185.42"
    builder   = "10.0.105.70"
    codecov   = "10.0.105.65"
    dns1      = "10.0.105.21"
    dns2      = "10.0.105.22"
    builder   = "10.0.105.70"
    eebuilder = "10.0.105.71"
    gitlab    = "10.0.105.42"
    k3s-node1 = "10.0.135.151"
    k3s-node2 = "10.0.135.152"
    k3s-node3 = "10.0.135.153"
    mailsrv   = "10.0.105.80"
    pihole1   = "10.0.105.18"
    pihole2   = "10.0.105.19"
    proxy     = "10.0.105.10"
    runner1   = "10.0.105.60"
    runner2   = "10.0.105.61"
    runner3   = "10.0.105.62"
    stash     = "10.0.185.232"
    stash2    = "10.0.185.233"
    vault     = "10.0.105.30"
    wireguard = "10.0.95.2"
  }
}