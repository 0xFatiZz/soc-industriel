# OT Agents — Industrial SOC | Purdue Model

> Wazuh agents installed on OT VMs to collect security logs.  
> Agents send logs to the **Wazuh Worker (DMZ)** — never directly to the Manager.

---

## Architecture

```
OT VMs (agents)                    DMZ Zone              SOC Zone
┌─────────────────────┐           ┌────────────┐        ┌──────────────┐
│ Engineering WS      │─[1514]───▶│            │        │              │
│ 192.168.30.10       │           │  Wazuh     │─[1514]▶│  Wazuh       │
│ ScadaBR             │─[1514]───▶│  Worker    │        │  Manager     │
│ 192.168.20.10       │           │  .35.10    │        │  .40.10      │
│ OpenPLC             │─[1514]───▶│            │        │              │
│ 192.168.10.10       │           └────────────┘        └──────────────┘
└─────────────────────┘
```

---

## Installation

Run the script on each OT VM :

### Engineering WS (192.168.30.10)
```bash
sudo bash scripts/install-agent-linux.sh engineering-ws
```

### ScadaBR (192.168.20.10)
```bash
sudo bash scripts/install-agent-linux.sh scadabr
```

### OpenPLC (192.168.10.10)
```bash
sudo bash scripts/install-agent-linux.sh openplc
```

---

## pfSense rules required

| Source | Destination | Port | Description |
|--------|-------------|------|-------------|
| OT zones (192.168.10-30.x) | DMZ (192.168.35.10) | 1514 | Agents → Wazuh Worker |
| OT zones | SOC (192.168.40.10) | any | ❌ Block — no direct access |

---

## Verify agents on Manager

```bash
sudo /var/ossec/bin/agent_control -l
```

Expected output :
```
ID: 001, Name: engineering-ws, IP: 192.168.30.10, Status: Active
ID: 002, Name: scadabr,        IP: 192.168.20.10, Status: Active
ID: 003, Name: openplc,        IP: 192.168.10.10, Status: Active
```

---

## Files

```
ot-agents/
├── scripts/
│   └── install-agent-linux.sh    # Agent installation script for Linux OT VMs
└── README.md                      # This file
```
