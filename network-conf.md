# Network Configuration — Industrial IT/OT SOC

This document describes the network architecture and configuration implemented for the industrial SOC lab, based on the Purdue model. It covers the global architecture, the segmentation performed via pfSense, the IP addressing of each level, and the Host-Only access network used for maintenance.

---

## 1. Global Network Architecture

The project's network infrastructure is based on the **Purdue model**, a reference architecture for segmenting industrial (OT) and IT networks. The model organizes the network into five hierarchical levels, each isolated from the others by a centralized **pfSense** firewall that holds all the segmentation interfaces.

> **Why this matters:** separating IT and OT into distinct levels limits the attack surface — a compromise on the office network (IT) cannot directly reach the field devices (OT), and vice versa. Every level-to-level flow has to pass through pfSense, which can inspect and filter it.

![Purdue model architecture diagram](images/figure-1.1-purdue-architecture.png)
*Figure 1.1 — Global network architecture (Purdue model)*

**Table 1.1 — Purdue levels and associated equipment**

| Level | Name | Role | Equipment |
|-------|------|------|-----------|
| Level 4/5 | Enterprise Network (IT) | Supervision & administration | Wazuh Manager, SOC workstation |
| Level 3.5 | Industrial DMZ | IT/OT buffer zone | Guacamole + Wazuh Worker |
| Level 3 | Operations / Engineering | IT/OT boundary | Engineering workstation |
| Level 2 | Supervisory Control (OT) | Process supervision | ScadaBR |
| Level 0/1 | Process Network (OT) | Field automation | OpenPLC, Factory I/O |

---

## 2. Network Segmentation via pfSense

Segmentation between the Purdue levels is provided by a single **pfSense 2.4.5-RELEASE-p1** instance, configured with several distinct network interfaces. Each interface corresponds to a virtual network segment (VirtualBox Internal Network or Bridged Network) dedicated to one level of the architecture, guaranteeing isolation and traffic control between the IT and OT domains.

### Adapter 1 — control-net (Level 0/1)
Internal Network `control-net`, used by the process/field level (OpenPLC, Factory I/O).

![pfSense Adapter 1 settings](net-conf\pfsense-adapter1.png) 
*Figure 1.2 — pfSense: Adapter 1 (control-net)*

### Adapter 2 — scada-net (Level 2)
Internal Network `scada-net`, used by the supervisory control level (ScadaBR).

![pfSense Adapter 2 settings](net-conf\pfsense-adapter2.png)
*Figure 1.3 — pfSense: Adapter 2 (scada-net)*

### Adapter 3 — ops-net (Level 3)
Internal Network `ops-net`, used by the operations/engineering level (engineering workstation).

![pfSense Adapter 3 settings](net-conf\pfsense-adapter3.png)
*Figure 1.4 — pfSense: Adapter 3 (ops-net)*

### Adapter 4 — dmz-net (Level 3.5)
Internal Network `dmz-net`, used by the industrial DMZ (Guacamole + Wazuh Worker).

![pfSense Adapter 4 settings](net-conf\pfsense-adapter4.png)
*Figure 1.5 — pfSense: Adapter 4 (dmz-net)*

### Adapter 5 — soc-net (Level 4/5)
Internal Network `soc-net`, used by the enterprise/SOC level (Wazuh Manager). Because VirtualBox's GUI limits a VM to 4 network adapters on the Basic settings tab, this interface was added from the command line using `VBoxManage`:

```
C:\Users\user>cd "C:\Program Files\Oracle\VirtualBox"

C:\Program Files\Oracle\VirtualBox>VBoxManage modifyvm "pfSense" --nic5 intnet --intnet5 "soc-net"
```

This attaches NIC 5 of the pfSense VM to the internal network `soc-net`, mirroring the same configuration pattern used for Adapters 1–4, but applied through the VirtualBox command-line interface instead of the settings window.

![pfSense Adapter 5 (soc-net) VBoxManage command](net-conf\pfsense-adapter5.png)
*Figure — pfSense: Adapter 5 (soc-net), configured via VBoxManage*

### Adapter 6 — WAN (NAT)
NAT attachment, giving pfSense (and, through it, the whole lab) external internet access via the host's connection. This interface acts as the WAN side of the firewall and is not part of the Purdue segmentation itself. It was switched from its previous attachment to NAT using `VBoxManage`:

```
C:\Users\user>cd "C:\Program Files\Oracle\VirtualBox"

C:\Program Files\Oracle\VirtualBox>VBoxManage modifyvm "pfSense" --nic6 nat
```

This reattaches NIC 6 of the pfSense VM to NAT, confirmed afterwards by the `showvminfo` output below (NIC 6: Attachment: NAT).

![pfSense Adapter 6 (WAN, NAT) settings](images/figure-1.x-pfsense-adapter6-wan.png)
*Figure — pfSense: Adapter 6 (WAN, NAT)*

### Interface overview
The full interface list, confirmed via `VBoxManage showvminfo`, and the IP assignment shown on the pfSense console at boot:

![VBoxManage showvminfo NIC list](net-conf\pfsense.png)
*Figure 1.6 — pfSense network interface list (VBoxManage showvminfo) — NIC 6 attached via NAT*

![pfSense console interface assignment](images/net-conf\pfsense-ip.png)
*Figure 1.7 — pfSense console: interface and IP assignment*

**Table 1.2 — pfSense interface configuration**

| Interface | Internal network | Role | Purdue level | IP address |
|-----------|------------------|------|--------------|------------|
| em5 (WAN) | NAT | External access | — | DHCP4: 10.0.7.15/24 |
| em4 (LAN) | soc-net | SOC | Level 4/5 | 192.168.40.1/24 |
| em3 (opt1) | dmz-net | DMZ | Level 3.5 | 192.168.35.1/24 |
| em2 (opt2) | ops-net | OPS | Level 3 | 192.168.30.1/24 |
| em1 (opt3) | scada-net | SCADA | Level 2 | 192.168.20.1/24 |
| em0 (opt4) | control-net | CONTROL | Level 0/1 | 192.168.10.1/24 |

---

## 3. Per-Level IP Configuration

Each host has a static IP on its Purdue-level segment, with the pfSense interface of that segment as its default gateway. This keeps every level's traffic routed through the firewall rather than switched directly.

### Level 0/1 — Process Network (OpenPLC)

The `plc_2` virtual machine, hosting the **OpenPLC** soft-PLC, has two network interfaces: the first attached to `control-net` for its place in the Purdue architecture, the second in **Host-Only** mode to allow direct access from the host machine.

![plc_2 Adapter 1 (control-net)](images/figure-1.8-plc2-adapter1.png)
*Figure 1.8 — plc_2: Adapter 1 (control-net)*

![plc_2 Adapter 2 (Host-Only)](images/figure-1.9-plc2-adapter2.png)
*Figure 1.9 — plc_2: Adapter 2 (Host-Only Ethernet Adapter)*

![plc_2 /etc/network/interfaces](images/figure-1.10-plc2-interfaces-file.png)
*Figure 1.10 — plc_2: `/etc/network/interfaces` file*

**Table 1.3 — IP addressing: plc_2 (OpenPLC)**

| Interface | Segment | IP address | Netmask | Gateway |
|-----------|---------|-----------|---------|---------|
| enp0s3 | control-net | 192.168.10.10 | 255.255.255.0 | 192.168.10.1 |
| enp0s8 | Host-Only | 192.168.56.10 | 255.255.255.0 | — |

### Level 2 — Supervisory Control Network (ScadaBR)

![ScadaBR Adapter 1 (scada-net)](images/figure-1.11-scadabr-adapter1.png)
*Figure 1.11 — ScadaBR: Adapter 1 (scada-net)*

![ScadaBR /etc/network/interfaces](images/figure-1.12-scadabr-interfaces-file.png)
*Figure 1.12 — ScadaBR: `/etc/network/interfaces` file*

**Table 1.4 — IP addressing: ScadaBR**

| Interface | Segment | IP address | Netmask | Gateway |
|-----------|---------|-----------|---------|---------|
| enp0s3 | scada-net | 192.168.20.10 | 255.255.255.0 | 192.168.20.1 |

### Level 3 — Operations / Engineering Network (Engineering workstation)

![workstation Adapter 1 (ops-net)](images/figure-1.13-workstation-adapter1.png)
*Figure 1.13 — workstation: Adapter 1 (ops-net)*

![workstation /etc/network/interfaces](images/figure-1.14-workstation-interfaces-file.png)
*Figure 1.14 — workstation: `/etc/network/interfaces` file*

**Table 1.5 — IP addressing: Engineering workstation**

| Interface | Segment | IP address | Netmask | Gateway |
|-----------|---------|-----------|---------|---------|
| eth0 | ops-net | 192.168.30.10 | 255.255.255.0 | 192.168.30.1 |

### Level 3.5 — Industrial DMZ (Guacamole + Wazuh Worker)

![Dmz Server Adapter 1 (dmz-net)](images/figure-1.15-dmzserver-adapter1.png)
*Figure 1.15 — Dmz Server: Adapter 1 (dmz-net)*

![Dmz Server netplan config](images/figure-1.16-dmzserver-netplan.png)
*Figure 1.16 — Dmz Server: `/etc/netplan/00-installer-config.yaml` file*

**Table 1.6 — IP addressing: Dmz Server (Guacamole + Wazuh Worker)**

| Interface | Segment | IP address | Netmask | Gateway |
|-----------|---------|-----------|---------|---------|
| enp0s3 | dmz-net | 192.168.35.10 | 255.255.255.0 (/24) | 192.168.35.1 |

### Level 4/5 — Enterprise Network (Wazuh Manager)

![Wazuh Manager Adapter 1 (soc-net)](images/figure-1.17-wazuh-adapter1.png)
*Figure 1.17 — Wazuh v4.14.5 OVA: Adapter 1 (soc-net)*

![Wazuh Manager network script](images/figure-1.18-wazuh-ifcfg-eth0.png)
*Figure 1.18 — Wazuh Manager: `/etc/sysconfig/network-scripts/ifcfg-eth0` file*

**Table 1.7 — IP addressing: Wazuh Manager**

| Interface | Segment | IP address | Prefix | Gateway | DNS |
|-----------|---------|-----------|--------|---------|-----|
| eth0 | soc-net | 192.168.40.10 | /24 | 192.168.40.1 | 8.8.8.8 |

---

## 4. Host-Only Network — Access from the Host Machine

In addition to the Purdue segmentation, a **Host-Only** network was configured under VirtualBox to allow direct access from the host machine to certain virtual machines (notably the `plc_2` PLC), without going through the full pfSense firewall chain. This link is what lets **Factory I/O**, which runs on the host machine, communicate over Modbus TCP with **OpenPLC** running inside `plc_2` — since Factory I/O is not itself a VM on the Purdue network, it needs this direct Host-Only path to reach the PLC.

![VirtualBox Host-Only Network manager](images/figure-1.19-vbox-hostonly-manager.png)
*Figure 1.19 — VirtualBox network manager: Host-Only Network*

![Host-Only adapter IP configuration on the host](images/figure-1.20-hostonly-ip-config.png)
*Figure 1.20 — Host-Only adapter IP configuration on the host machine*

![plc_2 Host-Only interface detail](images/figure-1.21-plc2-hostonly-detail.png)
*Figure 1.21 — plc_2: Host-Only interface detail (Adapter 2)*

**Table 1.8 — Host-Only network configuration**

| Parameter | Value |
|-----------|-------|
| Network type | VirtualBox Host-Only Ethernet Adapter |
| IPv4 prefix | 192.168.56.1/24 |
| DHCP server | Disabled |
| Host IP address | 192.168.56.1 |
| plc_2 IP address (enp0s8) | 192.168.56.10 |

---

## 5. IP Addressing Summary

**Table 1.9 — Global IP addressing plan**

| Purdue level | Machine | Segment (internal network) | IP address | Netmask | Gateway |
|--------------|---------|----------------------------|-----------|---------|---------|
| Level 0/1 | plc_2 (OpenPLC) | control-net | 192.168.10.10 | /24 | 192.168.10.1 |
| Level 0/1 (host access) | plc_2 (OpenPLC) | Host-Only | 192.168.56.10 | /24 | — |
| Level 2 | ScadaBR | scada-net | 192.168.20.10 | /24 | 192.168.20.1 |
| Level 3 | workstation | ops-net | 192.168.30.10 | /24 | 192.168.30.1 |
| Level 3.5 | Dmz Server | dmz-net | 192.168.35.10 | /24 | 192.168.35.1 |
| Level 4/5 | Wazuh Manager | soc-net | 192.168.40.10 | /24 | 192.168.40.1 |

**pfSense interfaces (gateway of each segment)**

| Purdue level | Interface | Segment | IP address | Netmask |
|--------------|-----------|---------|-----------|---------|
| Level 0/1 | pfSense (em0) | control-net | 192.168.10.1 | /24 |
| Level 2 | pfSense (em1) | scada-net | 192.168.20.1 | /24 |
| Level 3 | pfSense (em2) | ops-net | 192.168.30.1 | /24 |
| Level 3.5 | pfSense (em3) | dmz-net | 192.168.35.1 | /24 |
| Level 4/5 | pfSense (em4) | soc-net | 192.168.40.1 | /24 |

---

## 6. Segmentation Summary

The whole architecture relies on six distinct subnets (`control-net`, `scada-net`, `ops-net`, `dmz-net`, `soc-net`, and the Host-Only network), each isolated by a dedicated pfSense interface. This segmentation guarantees:

- **Strict isolation** between the OT domains (Level 0 to 2) and the IT domains (Level 3.5 to 5), in line with the Purdue model.
- **A single mandatory choke point** (pfSense) for any inter-level traffic, enabling filtering rules to be applied.
- **A buffer zone** (DMZ, Level 3.5) hosting remote-access services (Guacamole) and the supervision relay (Wazuh Worker), avoiding any direct access between the enterprise network and the OT network.
- **A maintenance access path** via the Host-Only network, independent from the firewall chain, for direct configuration needs from the host machine.
