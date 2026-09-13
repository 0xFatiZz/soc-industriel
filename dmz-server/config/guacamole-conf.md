# Guacamole Configuration — Industrial DMZ Remote Access Gateway

This document describes the deployment and configuration of Apache Guacamole as the controlled remote-access gateway for the industrial SOC lab.

---

## 1. Overview

**Apache Guacamole** is a clientless remote-access gateway that provides access to remote machines over SSH, RDP, or VNC directly from a web browser, without requiring a dedicated client to be installed on the user's workstation.

In this project, Guacamole was deployed on the **industrial DMZ server** (Level 3.5, address `192.168.35.10`), acting as a **single, controlled entry point** from the enterprise network toward the OT-level equipment (OpenPLC, ScadaBR) and toward the engineering workstation (EWS), which sits at the IT/OT boundary. This avoids any direct access between the enterprise network and the industrial network.

> **Why this matters:** without Guacamole, an admin would need direct network reachability (and often SSH keys/credentials) from the enterprise network straight into the OT zone — defeating the whole point of the Purdue segmentation. Routing every remote session through one DMZ gateway means there is a single place to control, log, and audit who accesses what.

---

## 2. Accessing the Guacamole Interface

The Guacamole administration interface is reachable at:

```
http://192.168.35.10:8080/guacamole/
```

![Apache Guacamole login page](config/guacamole/login.png)
*Figure 1 — Apache Guacamole login page*

After authenticating with the administrator account (`guacadmin`), the user lands on the main dashboard, initially empty until connections are configured.

![Guacamole dashboard with no connections configured](dmz-server/config/guacamole/1.png)
*Figure 2 — Guacamole dashboard: no connection configured yet*

---

## 3. Configuring Remote Connections

Three SSH connections were created to allow remote access, from the DMZ, to the three main targets on the industrial side: the **OpenPLC** automaton and the **ScadaBR** supervision system (both OT equipment), plus the **engineering workstation (EWS)**, which sits at the IT/OT boundary and is used to configure/maintain the OT equipment.

Each connection is configured with a name/location/protocol, then network and authentication parameters (hostname, port, username, password).

### OpenPLC-SSH connection

![Guacamole edit connection — OpenPLC-SSH](dmz-server/config/guacamole/2.png)
*Figure 3 — Guacamole: editing the OpenPLC-SSH connection*

![Guacamole network and authentication parameters — OpenPLC-SSH](dmz-server/config/guacamole/3.png)
*Figure 4 — Guacamole: network and authentication parameters for OpenPLC-SSH*

**Table 1 — Connection parameters: OpenPLC-SSH**

| Parameter | Value |
|-----------|-------|
| Name | OpenPLC-SSH |
| Location | ROOT |
| Protocol | SSH |
| Hostname | 192.168.10.10 |
| Port | 22 |
| Username | user |
| Password | (hidden) |

### ScadaBr-SSH connection

![Guacamole edit connection — ScadaBr-SSH](dmz-server/config/guacamole/4.png)
*Figure 5 — Guacamole: editing the ScadaBr-SSH connection*

![Guacamole network and authentication parameters — ScadaBr-SSH](dmz-server/config/guacamole/5.png)
*Figure 6 — Guacamole: network and authentication parameters for ScadaBr-SSH*

**Table 2 — Connection parameters: ScadaBr-SSH**

| Parameter | Value |
|-----------|-------|
| Name | ScadaBr-SSH |
| Location | ROOT |
| Protocol | SSH |
| Hostname | 192.168.20.10 |
| Port | 22 |
| Username | scadabr |
| Password | (hidden) |

### EWS-SSH connection

![Guacamole edit connection — EWS-SSH](dmz-server/config/guacamole/6.png)
*Figure 7 — Guacamole: editing the EWS-SSH connection*

![Guacamole network and authentication parameters — EWS-SSH](dmz-server/config/guacamole/7.png)
*Figure 8 — Guacamole: network and authentication parameters for EWS-SSH*

**Table 3 — Connection parameters: EWS-SSH**

| Parameter | Value |
|-----------|-------|
| Name | EWS-SSH |
| Location | ROOT |
| Protocol | SSH |
| Hostname | 192.168.30.10 |
| Port | 22 |
| Username | workstation |
| Password | (hidden) |

### Connections summary

![List of configured Guacamole connections](dmz-server/config/guacamole/8.png)
*Figure 9 — List of connections configured in Guacamole*

**Table 4 — Guacamole connections summary**

| Connection | Target | Purdue level | Protocol | Hostname | Username |
|------------|--------|--------------|----------|----------|----------|
| OpenPLC-SSH | OpenPLC automaton | Level 0/1 | SSH | 192.168.10.10 | user |
| ScadaBr-SSH | ScadaBR supervision | Level 2 | SSH | 192.168.20.10 | scadabr |
| EWS-SSH | Engineering workstation | Level 3 | SSH | 192.168.30.10 | workstation |

---

## 4. Associated Firewall Rules

To let the Guacamole server initiate SSH connections toward the lower-level equipment, dedicated filtering rules were added on the **DMZ** interface of the pfSense firewall. These rules apply the **principle of least privilege**: only SSH traffic (port 22) explicitly originating from the Guacamole server's address (`192.168.35.10`) toward the target hosts is allowed; every other flow is implicitly blocked.

![pfSense firewall rules on the DMZ interface](dmz-server/config/guacamole/10.png)
*Figure 10 — pfSense: firewall rules on the DMZ interface*

**Table 5 — Firewall rules: DMZ interface**

| Protocol | Source | Destination | Port | Description |
|----------|--------|-------------|------|-------------|
| IPv4 TCP | 192.168.35.10 | 192.168.30.10 | 22 (SSH) | Guacamole → EWS |
| IPv4 TCP | 192.168.35.10 | 192.168.20.10 | 22 (SSH) | Guacamole → ScadaBr |
| IPv4 TCP | 192.168.35.10 | 192.168.10.10 | 22 (SSH) | Guacamole → OpenPLC |

---

## 5. Testing and Validation

A browser-based connection test validated that the Guacamole gateway works correctly. The `OpenPLC-SSH` connection was initiated successfully, opening an interactive SSH session to the OpenPLC machine (Ubuntu 16.04.4 LTS) directly from the web interface, with no additional client-side configuration.

![Active SSH session to OpenPLC via Guacamole](dmz-server/config/guacamole/11.png)
*Figure 11 — Active SSH session to OpenPLC via Guacamole*

---

## 6. Summary

Deploying Guacamole inside the industrial DMZ centralizes and logs every remote access to sensitive (OT) equipment and to the engineering workstation, without exposing those machines directly to the enterprise network. Combined with the strict filtering rules applied on pfSense, this mechanism forms a single, auditable control point in line with best practices for securing segmented industrial architectures based on the Purdue model.
