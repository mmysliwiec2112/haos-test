variable "proxmox_endpoint" {
  description = "Proxmox VE API endpoint (e.g. https://pve.example.com:8006)."
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token in the form USER@REALM!TOKENID=SECRET."
  type        = string
  sensitive   = true
}

variable "proxmox_insecure" {
  description = "Skip TLS certificate verification for the Proxmox API."
  type        = bool
  default     = true
}

variable "node_name" {
  description = "Proxmox node name where LXC containers will be created."
  type        = string
}

variable "client_name" {
  description = "Short client identifier used in hostnames (lowercase alphanumeric/hyphen)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{0,30}[a-z0-9])?$", var.client_name))
    error_message = "client_name must be a valid DNS label (lowercase letters, digits, hyphens)."
  }
}

variable "client_tier" {
  description = "Subscription tier controlling which applications may be provisioned."
  type        = string

  validation {
    condition     = contains(["starter", "pro"], var.client_tier)
    error_message = "client_tier must be either \"starter\" or \"pro\"."
  }
}

variable "enabled_apps" {
  description = "Applications the client selected for deployment."
  type        = list(string)

  validation {
    condition = alltrue([
      for app in var.enabled_apps : contains(
        ["mosquitto", "adguard", "uptime-kuma", "n8n", "nocodb"],
        app
      )
    ])
    error_message = "enabled_apps may only contain: mosquitto, adguard, uptime-kuma, n8n, nocodb."
  }
}

variable "app_ips" {
  description = "Static IPv4 addresses (without CIDR suffix) keyed by application name."
  type        = map(string)
}

variable "app_vmids" {
  description = "Optional explicit VM/CT IDs keyed by application name. Omit entries to let Proxmox auto-assign."
  type        = map(number)
  default     = {}
}

variable "network_bridge" {
  description = "Proxmox bridge for container NICs (e.g. vmbr0)."
  type        = string
  default     = "vmbr0"
}

variable "network_gateway" {
  description = "IPv4 default gateway for containers."
  type        = string
}

variable "network_cidr_prefix" {
  description = "CIDR prefix length for static container addresses (e.g. 24)."
  type        = number
  default     = 24

  validation {
    condition     = var.network_cidr_prefix >= 8 && var.network_cidr_prefix <= 30
    error_message = "network_cidr_prefix must be between 8 and 30."
  }
}

variable "dns_servers" {
  description = "DNS resolvers injected into container initialization."
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
}

variable "ssh_public_key" {
  description = "OpenSSH public key injected into the container root account."
  type        = string
}

variable "ostemplate" {
  description = "LXC OS template volume ID on the Proxmox node."
  type        = string
  default     = "local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst"
}

variable "datastore_id" {
  description = "Datastore for container root disks."
  type        = string
  default     = "local-lvm"
}
