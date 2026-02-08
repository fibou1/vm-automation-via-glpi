resource "proxmox_virtual_environment_vm" "vm" {
  name      = var.vm_name
  node_name = var.vm_node

  clone {
    vm_id = var.template_id
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
    bridge = var.vm_bridge
    model  = "virtio"
  }

  cpu {
    cores = var.vm_cpu
  }

  memory {
    dedicated = var.vm_ram
  }
}
