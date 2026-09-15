# Wazuh Manager — Industrial SOC | Purdue Model

> **Zone:** SOC/IT (Level 4) — 192.168.40.10  
> **Network:** soc-net (VirtualBox Internal Network)  
> **Installed via:** Wazuh OVA

---

## Role

The Wazuh Manager is the central node of the SOC.  
It receives security logs from the Wazuh Worker (DMZ) and correlates alerts.  
The Dashboard runs on the same VM as the Manager.

```
OT Agents
   │
   ▼
Wazuh Worker (192.168.35.20)      ← DMZ Zone
   │  port 1514/1516
   ▼
Wazuh Manager + Dashboard         ← SOC Zone  (this server)
(192.168.40.10)
        ▲
        │  http — port 443/80
        │
SOC Analyst WS (192.168.40.2)    ← soc-net (same zone)
```

---

## Installation

Installed via the official **Wazuh OVA** — no installation script needed.  
Manager and Dashboard are bundled in the same VM.

Download : https://documentation.wazuh.com/current/deployment-options/virtual-machine/virtual-machine.html

---

## Configuration

Follow the guides in `config/` in this order :

### 1. Network
Configure the static IP via `ifcfg-eth0` :

```bash
sudo nano /etc/sysconfig/network-scripts/ifcfg-eth0
```

See `config/network-setup.md` for the full guide.

### 2. Wazuh Cluster
Configure the Manager as cluster master :

```bash
sudo nano /var/ossec/etc/ossec.conf
```

See `config/wazuh-manager-setup.md` for the full guide.

---

## Files

```
wazuh-manager/
├── config/
│   ├── network-setup.md           # Static IP configuration (ifcfg-eth0)
│   └── wazuh-manager-setup.md    # Cluster master configuration guide
└── README.md                      # This file
```

---

## Access

> The Wazuh Manager and Dashboard are accessible from **soc-net only** (192.168.40.0/24).  
> The SOC Analyst WS (192.168.40.2) must be on the same network to access the Dashboard.

| Service | URL | Login |
|---------|-----|-------|
| Wazuh Dashboard | https://192.168.40.10 | admin / admin |
| Wazuh API | https://192.168.40.10:55000 | wazuh / wazuh |

---

## pfSense rules required

| Source | Destination | Port | Description |
|--------|-------------|------|-------------|
| DMZ (192.168.35.20) | SOC (192.168.40.10) | 1514, 1516 | Worker → Manager (cluster) |
| SOC (192.168.40.2) | SOC (192.168.40.10) | 443, 80 | Analyst → Dashboard |
| SOC (192.168.40.2) | SOC (192.168.40.10) | 55000 | Analyst → Wazuh API |
| OT zones | SOC (192.168.40.10) | any | ❌ Block — no direct OT access |
