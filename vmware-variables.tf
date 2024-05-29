data "vsphere_datacenter" "datacenter" {
  name = "Example.com"
}

data "vsphere_datastore" "datastore" {
  name          = "TrueNAS"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datastore" "vsan" {
  name          = "vsanDatastore"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "Texas"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "dmz" {
  name          = "DMZ"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "k8s" {
  name          = "Kubernetes"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "monitoring" {
  name          = "Monitoring"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "server" {
  name          = "Server"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "vpn" {
  name          = "VPN"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "oel9" {
  name          = "OEL - 9"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "rhel9" {
  name          = "RHEL - 9"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "ubuntu22" {
  name          = "Ubuntu - 22.04"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_virtual_machine" "ubuntu24" {
  name          = "Ubuntu - 24.04"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_resource_pool" "pool" {
  name          = "Terraform"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_folder" "terraform" {
  path          = "Terraform"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}