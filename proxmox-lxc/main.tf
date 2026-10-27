resource "proxmox_virtual_environment_container" "app" {
  for_each = local.apps_to_create

  node_name    = var.node_name
  vm_id        = lookup(var.app_vmids, each.key, null)
  description  = "${each.value.description} — client ${var.client_name} (${var.client_tier})"
  tags         = each.value.tags
  unprivileged = true
  started      = true

  cpu {
    cores = each.value.cores
  }

  memory {
    dedicated = each.value.memory_mb
    swap      = each.value.swap_mb
  }

  disk {
    datastore_id = var.datastore_id
    size         = each.value.disk_gb
  }

  network_interface {
    name   = "eth0"
    bridge = var.network_bridge
  }

  operating_system {
    template_file_id = var.ostemplate
    type             = "debian"
  }

  initialization {
    hostname = each.value.hostname

    dns {
      servers = var.dns_servers
    }

    ip_config {
      ipv4 {
        address = "${each.value.ipv4}/${var.network_cidr_prefix}"
        gateway = var.network_gateway
      }
    }

    user_account {
      keys = [trimspace(var.ssh_public_key)]
    }
  }
}
