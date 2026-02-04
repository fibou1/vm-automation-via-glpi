output "pm_api_url" {
  value = var.pm_api_url
}

output "vmTEST_ipv4" {
  value = proxmox_virtual_environment_vm.vmTEST.ipv4_addresses
}