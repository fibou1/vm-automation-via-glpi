# ===== CONNEXION PROXMOX =====
variable "pm_api_url" {
  type = string
}

variable "pm_api_token_id" {
  type      = string
  sensitive = true
}

variable "pm_api_token_secret" {
  type      = string
  sensitive = true
}

variable "pm_tls_insecure" {
  type      = bool
  sensitive = true
}

# ===== PARAMÈTRES VM =====
variable "template_id" {
  description = "ID du template Proxmox à cloner"
  type        = number
  default     = 102
}

variable "vm_name" {
  description = "Nom de la VM"
  type        = string
  default     = "vm-auto"
}

variable "vm_node" {
  description = "Node Proxmox cible"
  type        = string
  default     = "A51"
}

variable "vm_cpu" {
  description = "Nombre de CPU cores"
  type        = number
  default     = 1
}

variable "vm_ram" {
  description = "RAM en MB"
  type        = number
  default     = 1024
}

variable "vm_disk" {
  description = "Taille disque (ex: 20G)"
  type        = string
  default     = "20G"
}

variable "vm_bridge" {
  description = "Network bridge"
  type        = string
  default     = "vmbr0"
}
