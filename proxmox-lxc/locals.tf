locals {
  # Applications permitted per subscription tier.
  tier_allowed_apps = {
    starter = ["mosquitto", "adguard", "uptime-kuma"]
    pro     = ["mosquitto", "adguard", "uptime-kuma", "n8n", "nocodb"]
  }

  # Catalog: resource limits, category tag, and human-readable description.
  app_catalog = {
    mosquitto = {
      category    = "iot"
      description = "MQTT broker (Mosquitto)"
      cores       = 1
      memory_mb   = 256
      swap_mb     = 256
      disk_gb     = 4
    }
    adguard = {
      category    = "network"
      description = "DNS sinkhole (AdGuard Home)"
      cores       = 1
      memory_mb   = 512
      swap_mb     = 512
      disk_gb     = 4
    }
    uptime-kuma = {
      category    = "monitoring"
      description = "Uptime monitoring (Uptime Kuma)"
      cores       = 1
      memory_mb   = 512
      swap_mb     = 512
      disk_gb     = 8
    }
    n8n = {
      category    = "automation"
      description = "Workflow automation (n8n)"
      cores       = 2
      memory_mb   = 2048
      swap_mb     = 512
      disk_gb     = 16
    }
    nocodb = {
      category    = "database"
      description = "No-code database (NocoDB)"
      cores       = 2
      memory_mb   = 1024
      swap_mb     = 512
      disk_gb     = 16
    }
  }

  allowed_for_tier = toset(local.tier_allowed_apps[var.client_tier])
  enabled_set      = toset(var.enabled_apps)

  # Selected by the client AND permitted by their tier.
  apps_eligible = {
    for app, cfg in local.app_catalog :
    app => cfg
    if contains(local.enabled_set, app) && contains(local.allowed_for_tier, app)
  }

  missing_ips = [
    for app in keys(local.apps_eligible) : app
    if !contains(keys(var.app_ips), app)
  ]

  # Final map used by for_each — only apps that also have a static IP.
  apps_to_create = {
    for app, cfg in local.apps_eligible :
    app => merge(cfg, {
      ipv4     = var.app_ips[app]
      hostname = "${var.client_name}-${app}"
      tags = [
        "tier:${var.client_tier}",
        cfg.category,
        "lxc",
      ]
    })
    if contains(keys(var.app_ips), app)
  }
}

check "app_ips_for_created_containers" {
  assert {
    condition     = length(local.missing_ips) == 0
    error_message = "app_ips must define a static IP for every app that will be created: ${join(", ", local.missing_ips)}"
  }
}
