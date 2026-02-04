resource "proxmox_virtual_environment_vm" "vm-via-glpi-test" {
  name      = "vm-via-glpi"
  node_name = "A51"

  clone {
    vm_id = 301
  }

  agent {
    enabled = true
  }

  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }
  }

  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  cpu {
    cores = 1
  }

  memory {
    dedicated = 2048
  }
}

