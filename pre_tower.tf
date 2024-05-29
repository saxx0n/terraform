resource "vsphere_virtual_machine" "proxy" {
  name                   = "proxy"
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true
  resource_pool_id       = data.vsphere_resource_pool.pool.id
  datastore_id           = data.vsphere_datastore.vsan.id
  num_cpus               = 1
  memory                 = 1024
  guest_id               = data.vsphere_virtual_machine.ubuntu22.guest_id
  folder                 = "Terraform"

  network_interface {
    network_id     = data.vsphere_network.server.id
    adapter_type   = data.vsphere_virtual_machine.ubuntu22.network_interface_types[0]
    mac_address    = var.mac_addr["proxy"]
    use_static_mac = true
  }

  disk {
    label            = "disk0"
    eagerly_scrub    = data.vsphere_virtual_machine.ubuntu22.disks[0].eagerly_scrub
    size             = data.vsphere_virtual_machine.ubuntu22.disks[0].size
    thin_provisioned = data.vsphere_virtual_machine.ubuntu22.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.ubuntu22.id

    customize {
      linux_options {
        host_name = "proxy"
        domain    = local.domain
      }

      network_interface {
        ipv4_address = var.ip_addr["proxy"]
        ipv4_netmask = var.netmask["servers"]
      }

      ipv4_gateway    = var.gateway["servers"]
      dns_server_list = ["8.8.8.8"]
      dns_suffix_list = [local.domain]
    }
  }

  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
      ept_rvi_mode,
      hv_mode
    ]
  }

  connection {
    type        = "ssh"
    user        = "ansible"
    private_key = file("~/.ssh/id_rsa_ansible")
    host        = var.ip_addr["proxy"]
  }

  provisioner "remote-exec" {
    script = "scripts/wait_for_instance.sh"
  }

  provisioner "local-exec" {
    command = "ansible-playbook ${local.ansible_args} -i '${var.ip_addr["proxy"]},' ansible/playbooks/create_proxy.yml"
  }
}

resource "vsphere_virtual_machine" "pi-hole1" {
  name                   = "pi-hole1"
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true
  resource_pool_id       = data.vsphere_resource_pool.pool.id
  datastore_id           = data.vsphere_datastore.vsan.id
  num_cpus               = 1
  memory                 = 1024
  guest_id               = data.vsphere_virtual_machine.ubuntu22.guest_id
  folder                 = "Terraform"

  depends_on = [vsphere_virtual_machine.proxy]

  network_interface {
    network_id     = data.vsphere_network.server.id
    adapter_type   = data.vsphere_virtual_machine.ubuntu22.network_interface_types[0]
    mac_address    = var.mac_addr["pihole1"]
    use_static_mac = true
  }

  disk {
    label            = "disk0"
    eagerly_scrub    = data.vsphere_virtual_machine.ubuntu22.disks[0].eagerly_scrub
    size             = data.vsphere_virtual_machine.ubuntu22.disks[0].size
    thin_provisioned = data.vsphere_virtual_machine.ubuntu22.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.ubuntu22.id

    customize {
      linux_options {
        host_name = "pi-hole1"
        domain    = local.domain
      }

      network_interface {
        ipv4_address = var.ip_addr["pihole1"]
        ipv4_netmask = var.netmask["servers"]
      }

      ipv4_gateway    = var.gateway["servers"]
      dns_server_list = ["1.1.1.1", "8.8.8.8"]
      dns_suffix_list = [local.domain]
    }
  }

  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
      ept_rvi_mode,
      hv_mode
    ]
  }

  connection {
    type        = "ssh"
    user        = "ansible"
    private_key = file("~/.ssh/id_rsa_ansible")
    host        = var.ip_addr["pihole1"]
  }

  provisioner "remote-exec" {
    script = "scripts/wait_for_instance.sh"
  }

  provisioner "local-exec" {
    command = "ansible-playbook ${local.ansible_args} -i '${var.ip_addr["pihole1"]},' ansible/playbooks/create_pihole.yml"
  }
}

resource "vsphere_virtual_machine" "dns-node1" {
  name                   = "dns-node1"
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true
  resource_pool_id       = data.vsphere_resource_pool.pool.id
  datastore_id           = data.vsphere_datastore.vsan.id
  num_cpus               = 1
  memory                 = 1024
  guest_id               = data.vsphere_virtual_machine.ubuntu22.guest_id
  folder                 = "Terraform"

  depends_on = [vsphere_virtual_machine.pi-hole1]

  network_interface {
    network_id     = data.vsphere_network.server.id
    adapter_type   = data.vsphere_virtual_machine.ubuntu22.network_interface_types[0]
    mac_address    = var.mac_addr["dns1"]
    use_static_mac = true
  }

  disk {
    label            = "disk0"
    eagerly_scrub    = data.vsphere_virtual_machine.ubuntu22.disks[0].eagerly_scrub
    size             = data.vsphere_virtual_machine.ubuntu22.disks[0].size
    thin_provisioned = data.vsphere_virtual_machine.ubuntu22.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.ubuntu22.id

    customize {
      linux_options {
        host_name = "dns-node1"
        domain    = local.domain
      }

      network_interface {
        ipv4_address = var.ip_addr["dns1"]
        ipv4_netmask = var.netmask["servers"]
      }

      ipv4_gateway    = var.gateway["servers"]
      dns_server_list = local.dns
      dns_suffix_list = [local.domain]
    }
  }

  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
      ept_rvi_mode,
      hv_mode
    ]
  }

  connection {
    type        = "ssh"
    user        = "ansible"
    private_key = file("~/.ssh/id_rsa_ansible")
    host        = var.ip_addr["dns1"]
  }

  provisioner "remote-exec" {
    script = "scripts/wait_for_instance.sh"
  }

  provisioner "local-exec" {
    command = "ansible-playbook ${local.ansible_args} -i '${var.ip_addr["dns1"]},' ansible/playbooks/create_dns.yml"
  }
}

resource "dns_a_record_set" "vault" {
  zone      = "example.com."
  name      = "vault"
  addresses = [var.ip_addr["vault"]]

  depends_on = [vsphere_virtual_machine.dns-node1]
}

resource "dns_ptr_record" "vault" {
  zone = "105.0.10.in-addr.arpa."
  name = element(split(".", var.ip_addr["vault"]), 3)
  ptr  = "vault.example.com."

  depends_on = [vsphere_virtual_machine.dns-node1]

}

resource "vsphere_virtual_machine" "vault" {
  name                   = "vault"
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true
  resource_pool_id       = data.vsphere_resource_pool.pool.id
  datastore_id           = data.vsphere_datastore.vsan.id
  num_cpus               = 1
  memory                 = 1024
  guest_id               = data.vsphere_virtual_machine.ubuntu22.guest_id
  folder                 = "Terraform"

  depends_on = [
    dns_a_record_set.vault,
    dns_ptr_record.vault
  ]

  network_interface {
    network_id     = data.vsphere_network.server.id
    adapter_type   = data.vsphere_virtual_machine.ubuntu22.network_interface_types[0]
    mac_address    = var.mac_addr["vault"]
    use_static_mac = true
  }

  disk {
    label            = "disk0"
    eagerly_scrub    = data.vsphere_virtual_machine.ubuntu22.disks[0].eagerly_scrub
    size             = data.vsphere_virtual_machine.ubuntu22.disks[0].size
    thin_provisioned = data.vsphere_virtual_machine.ubuntu22.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.ubuntu22.id

    customize {
      linux_options {
        host_name = "vault"
        domain    = local.domain
      }

      network_interface {
        ipv4_address = var.ip_addr["vault"]
        ipv4_netmask = var.netmask["servers"]
      }

      ipv4_gateway    = var.gateway["servers"]
      dns_server_list = local.dns
      dns_suffix_list = [local.domain]
    }
  }

  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
      ept_rvi_mode,
      hv_mode
    ]
  }

  connection {
    type        = "ssh"
    user        = "ansible"
    private_key = file("~/.ssh/id_rsa_ansible")
    host        = var.ip_addr["vault"]
  }

  provisioner "remote-exec" {
    script = "scripts/wait_for_instance.sh"
  }

  provisioner "local-exec" {
    command = "ansible-playbook ${local.ansible_args} -i '${var.ip_addr["vault"]},' ansible/playbooks/create_vault.yml"
  }
}

resource "dns_a_record_set" "gitlab" {
  zone      = "example.com."
  name      = "gitlab"
  addresses = [var.ip_addr["gitlab"]]

  depends_on = [vsphere_virtual_machine.vault]
}

resource "dns_ptr_record" "gitlab" {
  zone = "105.0.10.in-addr.arpa."
  name = element(split(".", var.ip_addr["gitlab"]), 3)
  ptr  = "gitlab.example.com."

  depends_on = [vsphere_virtual_machine.vault]

}

resource "dns_cname_record" "registry" {
  zone  = "example.com."
  name  = "registry"
  cname = "gitlab.example.com."

  depends_on = [dns_a_record_set.gitlab]
}

resource "vsphere_virtual_machine" "gitlab" {
  name                   = "gitlab"
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true
  resource_pool_id       = data.vsphere_resource_pool.pool.id
  datastore_id           = data.vsphere_datastore.vsan.id
  num_cpus               = 4
  memory                 = 8192
  guest_id               = data.vsphere_virtual_machine.ubuntu22.guest_id
  folder                 = "Terraform"

  depends_on = [
    dns_cname_record.registry,
    dns_a_record_set.gitlab,
    dns_ptr_record.gitlab
  ]

  network_interface {
    network_id     = data.vsphere_network.server.id
    adapter_type   = data.vsphere_virtual_machine.ubuntu22.network_interface_types[0]
    mac_address    = var.mac_addr["gitlab"]
    use_static_mac = true
  }

  disk {
    label            = "disk0"
    eagerly_scrub    = data.vsphere_virtual_machine.ubuntu22.disks[0].eagerly_scrub
    size             = 64
    thin_provisioned = data.vsphere_virtual_machine.ubuntu22.disks[0].thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.ubuntu22.id

    customize {
      linux_options {
        host_name = "gitlab"
        domain    = local.domain
      }

      network_interface {
        ipv4_address = var.ip_addr["gitlab"]
        ipv4_netmask = var.netmask["servers"]
      }

      ipv4_gateway    = var.gateway["servers"]
      dns_server_list = local.dns
      dns_suffix_list = [local.domain]
    }
  }

  lifecycle {
    ignore_changes = [
      clone[0].template_uuid,
      ept_rvi_mode,
      hv_mode
    ]
  }

  connection {
    type        = "ssh"
    user        = "ansible"
    private_key = file("~/.ssh/id_rsa_ansible")
    host        = var.ip_addr["gitlab"]
  }

  provisioner "remote-exec" {
    script = "scripts/wait_for_instance.sh"
  }

  provisioner "local-exec" {
    command = "ansible-playbook ${local.ansible_args} -i '${var.ip_addr["gitlab"]},' ansible/playbooks/create_gitlab.yml"
  }
}