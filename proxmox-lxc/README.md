# Proxmox LXC — provisioning per plan klienta

Moduł Terraform (`bpg/proxmox`) tworzy **tylko** kontenery LXC dla aplikacji, które klient wybrał i na które pozwala jego `client_tier`. Samych usług (Mosquitto, n8n, …) nie instaluje — to osobna warstwa konfiguracji.

## Plany

| Tier | Dozwolone aplikacje |
|------|---------------------|
| `starter` | `mosquitto`, `adguard`, `uptime-kuma` |
| `pro` | wszystko ze starter + `n8n`, `nocodb` |

Każdy kontener dostaje tagi: `tier:<plan>`, kategorię (`iot` / `network` / `monitoring` / `automation` / `database`) oraz `lxc`.

## Wymagania

- Terraform `>= 1.5`
- Proxmox VE z API tokenem
- Szablon LXC (domyślnie `local:vztmpl/debian-12-standard_12.7-1_amd64.tar.zst`)

## Uruchomienie

```bash
cd proxmox-lxc
cp terraform.tfvars.example terraform.tfvars
# uzupełnij endpoint, token, IP, klucz SSH

terraform init
terraform plan
terraform apply
```

Przykład w `terraform.tfvars.example`: klient `starter` z `mosquitto` + `uptime-kuma` (dwa kontenery, bez n8n/nocodb).

Token możesz też podać zmienną środowiskową `PROXMOX_VE_API_TOKEN` zamiast trzymać go w `tfvars`.
