resource "dns_a_record_set" "aap-ctrl" {
  zone      = "example.com."
  name      = "aap-ctrl"
  addresses = [var.ip_addr["aap-ctrl"]]

  depends_on = [vsphere_virtual_machine.gitlab]
}

resource "dns_a_record_set" "aap-work1" {
  zone      = "example.com."
  name      = "aap-work1"
  addresses = [var.ip_addr["aap-work1"]]

  depends_on = [vsphere_virtual_machine.gitlab]
}

resource "dns_a_record_set" "aap-work2" {
  zone      = "example.com."
  name      = "aap-work2"
  addresses = [var.ip_addr["aap-work2"]]

  depends_on = [vsphere_virtual_machine.gitlab]
}

resource "dns_ptr_record" "aap-ctrl" {
  zone = "145.0.10.in-addr.arpa."
  name = element(split(".", var.ip_addr["aap-ctrl"]), 3)
  ptr  = "aap-ctrl.example.com."

  depends_on = [vsphere_virtual_machine.gitlab]

}

resource "dns_ptr_record" "aap-work1" {
  zone = "145.0.10.in-addr.arpa."
  name = element(split(".", var.ip_addr["aap-work1"]), 3)
  ptr  = "aap-work1.example.com."

  depends_on = [vsphere_virtual_machine.gitlab]

}

resource "dns_ptr_record" "aap-work2" {
  zone = "145.0.10.in-addr.arpa."
  name = element(split(".", var.ip_addr["aap-work2"]), 3)
  ptr  = "aap-work2.example.com."

  depends_on = [vsphere_virtual_machine.gitlab]

}

resource "vsphere_virtual_machine" "aap-ctrl" {
  name                   = "aap-ctrl"
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true
  resource_pool_id       = data.vsphere_resource_pool.pool.id
  datastore_id           = data.vsphere_datastore.vsan.id
  num_cpus               = 4
  memory                 = 8192
  guest_id               = data.vsphere_virtual_machine.rhel9.guest_id
  folder                 = "Terraform"

  depends_on = [
    dns_a_record_set.aap-ctrl,
    dns_ptr_record.aap-ctrl
  ]

  network_interface {
    network_id     = data.vsphere_network.monitoring.id
    adapter_type   = data.vsphere_virtual_machine.rhel9.network_interface_types[0]
    mac_address    = var.mac_addr["aap-ctrl"]
    use_static_mac = true
  }

  disk {
    label            = "disk0"
    eagerly_scrub    = data.vsphere_virtual_machine.rhel9.disks[0].eagerly_scrub
    size             = data.vsphere_virtual_machine.rhel9.disks[0].size
    thin_provisioned = data.vsphere_virtual_machine.rhel9.disks[0].thin_provisioned
  }

  disk {
    label            = "disk1"
    eagerly_scrub    = data.vsphere_virtual_machine.rhel9.disks[0].eagerly_scrub
    size             = 64
    thin_provisioned = data.vsphere_virtual_machine.rhel9.disks[0].thin_provisioned
    unit_number      = 1

  }

  clone {
    template_uuid = data.vsphere_virtual_machine.rhel9.id

    customize {
      linux_options {
        host_name = "aap-ctrl"
        domain    = local.domain
      }

      network_interface {
        ipv4_address = var.ip_addr["aap-ctrl"]
        ipv4_netmask = var.netmask["monitoring"]
      }

      ipv4_gateway    = var.gateway["monitoring"]
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

  provisioner "local-exec" {
    command = "ansible-playbook ${local.ansible_args} -i '${var.ip_addr["aap-ctrl"]},' ansible/playbooks/create_rhel.yml"
  }
}

resource "vsphere_virtual_machine" "aap-work1" {
  name                   = "aap-work1"
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true
  resource_pool_id       = data.vsphere_resource_pool.pool.id
  datastore_id           = data.vsphere_datastore.vsan.id
  num_cpus               = 4
  memory                 = 8192
  guest_id               = data.vsphere_virtual_machine.rhel9.guest_id
  folder                 = "Terraform"

  depends_on = [
    dns_a_record_set.aap-work1,
    dns_ptr_record.aap-work1
  ]

  network_interface {
    network_id     = data.vsphere_network.monitoring.id
    adapter_type   = data.vsphere_virtual_machine.rhel9.network_interface_types[0]
    mac_address    = var.mac_addr["aap-work1"]
    use_static_mac = true
  }

  disk {
    label            = "disk0"
    eagerly_scrub    = data.vsphere_virtual_machine.rhel9.disks[0].eagerly_scrub
    size             = data.vsphere_virtual_machine.rhel9.disks[0].size
    thin_provisioned = data.vsphere_virtual_machine.rhel9.disks[0].thin_provisioned
  }

  disk {
    label            = "disk1"
    eagerly_scrub    = data.vsphere_virtual_machine.rhel9.disks[0].eagerly_scrub
    size             = 64
    thin_provisioned = data.vsphere_virtual_machine.rhel9.disks[0].thin_provisioned
    unit_number      = 1
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.rhel9.id

    customize {
      linux_options {
        host_name = "aap-work1"
        domain    = local.domain
      }

      network_interface {
        ipv4_address = var.ip_addr["aap-work1"]
        ipv4_netmask = var.netmask["monitoring"]
      }

      ipv4_gateway    = var.gateway["monitoring"]
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

  provisioner "local-exec" {
    command = "ansible-playbook ${local.ansible_args} -i '${var.ip_addr["aap-work1"]},' ansible/playbooks/create_rhel.yml"
  }
}

resource "vsphere_virtual_machine" "aap-work2" {
  name                   = "aap-work2"
  cpu_hot_add_enabled    = true
  memory_hot_add_enabled = true
  resource_pool_id       = data.vsphere_resource_pool.pool.id
  datastore_id           = data.vsphere_datastore.vsan.id
  num_cpus               = 4
  memory                 = 8192
  guest_id               = data.vsphere_virtual_machine.rhel9.guest_id
  folder                 = "Terraform"

  depends_on = [
    dns_a_record_set.aap-work2,
    dns_ptr_record.aap-work2
  ]

  network_interface {
    network_id     = data.vsphere_network.monitoring.id
    adapter_type   = data.vsphere_virtual_machine.rhel9.network_interface_types[0]
    mac_address    = var.mac_addr["aap-work2"]
    use_static_mac = true
  }

  disk {
    label            = "disk0"
    eagerly_scrub    = data.vsphere_virtual_machine.rhel9.disks[0].eagerly_scrub
    size             = data.vsphere_virtual_machine.rhel9.disks[0].size
    thin_provisioned = data.vsphere_virtual_machine.rhel9.disks[0].thin_provisioned
  }

  disk {
    label            = "disk1"
    eagerly_scrub    = data.vsphere_virtual_machine.rhel9.disks[0].eagerly_scrub
    size             = 64
    thin_provisioned = data.vsphere_virtual_machine.rhel9.disks[0].thin_provisioned
    unit_number      = 1

  }

  clone {
    template_uuid = data.vsphere_virtual_machine.rhel9.id

    customize {
      linux_options {
        host_name = "aap-work2"
        domain    = local.domain
      }

      network_interface {
        ipv4_address = var.ip_addr["aap-work2"]
        ipv4_netmask = var.netmask["monitoring"]
      }

      ipv4_gateway    = var.gateway["monitoring"]
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

  provisioner "local-exec" {
    command = "ansible-playbook ${local.ansible_args} -i '${var.ip_addr["aap-work2"]},' ansible/playbooks/create_rhel.yml"
  }
}

resource "vsphere_compute_cluster_vm_anti_affinity_rule" "aap" {
  name               = "vm-anti-affinity-rule-aap"
  compute_cluster_id = data.vsphere_compute_cluster.cluster.id
  virtual_machine_ids = [
    vsphere_virtual_machine.aap-ctrl.id,
    vsphere_virtual_machine.aap-work1.id,
    vsphere_virtual_machine.aap-work2.id
  ]

  depends_on = [
    vsphere_virtual_machine.aap-ctrl,
    vsphere_virtual_machine.aap-work1,
    vsphere_virtual_machine.aap-work2
  ]
}

resource "dns_cname_record" "tower" {
  zone  = "example.com."
  name  = "tower"
  cname = "aap-ctrl.example.com."

  depends_on = [
    vsphere_virtual_machine.aap-ctrl,
    vsphere_virtual_machine.aap-work1,
    vsphere_virtual_machine.aap-work2
  ]
}

resource "null_resource" "install_tower" {
  depends_on = [dns_cname_record.tower]

  provisioner "local-exec" {
    command = "ansible-playbook ${local.ansible_args} -i 'aap-ctrl,aap-work1,aap-work2,' ansible/playbooks/create_tower.yml"
  }
}

resource "null_resource" "configure_tower" {
  depends_on = [null_resource.install_tower]

  provisioner "local-exec" {
    command = "ansible-playbook -c local ansible/playbooks/configure_aap.yml"
  }
}

resource "null_resource" "run_aap" {
  depends_on = [null_resource.configure_tower]

  provisioner "local-exec" {
    command = "python3 scripts/run_job.py -s tower.example.com -u admin -p ${local.aap_password} -j 'Configure AAP' -t none"
  }
}

resource "null_resource" "fix_base" {
  depends_on = [null_resource.run_aap]

  provisioner "local-exec" {
    command = "python3 scripts/run_job.py -s tower.example.com -u admin -p ${local.aap_password} -j 'Configure BaseOS' -t none"
  }
}