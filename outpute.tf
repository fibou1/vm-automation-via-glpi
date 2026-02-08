output "pm_api_url" {
  value = var.pm_api_url
}

output "vm_id" {
  description = "ID de la VM créée"
  value       = proxmox_virtual_environment_vm.vm.id
}

output "vm_name" {
  description = "Nom de la VM"
  value       = proxmox_virtual_environment_vm.vm.name
}

output "vm_ipv4" {
  description = "Adresses IPv4 de la VM"
  value       = proxmox_virtual_environment_vm.vm.ipv4_addresses
}
