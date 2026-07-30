# DMZ Server — Industrial SOC | Purdue Model

> **Zone:** DMZ (Level 3.5) — 192.168.35.10  
> **Role:** Wazuh Worker + Guacamole Jump Server  
> **Network:** dmz-net (VirtualBox Internal Network)

---

## What is this server ?

The DMZ Server sits between the IT zone (SOC) and the OT zone (industrial network).  
It serves two purposes :

| Role | Tool | Description |
|------|------|-------------|
| **Jump Server** | Apache Guacamole | Single controlled access point to OT VMs via browser (RDP/SSH) |
| **Log Collector** | Wazuh Worker | Collects security logs from OT agents and forwards them to the Wazuh Manager |



## Requirements

- OS : Ubuntu Server 22.04 LTS
- RAM : 2 GB minimum
- Disk : 20 GB minimum
- Network adapter : dmz-net (192.168.35.0/24)

---

## Installation order

### Step 1 — Configure static IP

```bash
sudo cp config/netplan.yaml /etc/netplan/01-static.yaml
# Edit the interface name if needed (check with : ip link show)
sudo netplan apply
ip a show enp0s3  # verify : should show 192.168.35.20/24
```

### Step 2 — Install Guacamole (Jump Server)

```bash
sudo bash scripts/install-guacamole.sh
```

Access Guacamole :
```
URL      : http://192.168.35.20:8080/guacamole
Login    : guacadmin
Password : guacadmin
```
> ⚠️ Change the password after first login.

### Step 3 — Install Wazuh Worker

```bash
sudo bash scripts/install-wazuh-worker.sh
```

### Step 4 — Configure Wazuh Worker

Follow the guide in `config/wazuh-worker-setup.md` to :
- Set the cluster key (must match the Manager)
- Configure OT agent reception
- Verify the cluster connection

### Step 5 — Verify everything

```bash
sudo bash scripts/verify.sh
```

---

## Files

```
dmz-server/
├── scripts/
│   ├── install-guacamole.sh      # Install Guacamole via Docker
│   └── install-wazuh-worker.sh   # Install Wazuh Worker
├── config/
│   ├── netplan.yaml              # Static IP configuration
│   └── wazuh-worker-setup.md    # Wazuh ossec.conf configuration guide
└── README.md                    
```

---

## pfSense rules required

| Source | Destination | Port | Description |
|--------|-------------|------|-------------|
| SOC (192.168.40.2) | DMZ (192.168.35.20) | 8080 | SOC Analyst → Guacamole |
| DMZ (192.168.35.20) | OT zones | 22, 3389 | Jump Server → OT VMs |
| OT zones | DMZ (192.168.35.20) | 1514 | OT agents → Wazuh Worker |
| DMZ (192.168.35.20) | SOC (192.168.40.10) | 1514, 1516 | Worker → Wazuh Manager |
