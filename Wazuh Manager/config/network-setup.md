# Network Configuration Guide — Wazuh Manager (SOC Zone)

> **VM:** Wazuh Manager — 192.168.40.10  
> **Zone:** SOC/IT (Level 4) — soc-net  
> **Method:** /etc/sysconfig/network-scripts/ifcfg-eth0

---

## Step 1 — Open the network config file

```bash
sudo nano /etc/sysconfig/network-scripts/ifcfg-eth0
```

---

## Step 2 — Replace the content with

```
DEVICE=eth0
BOOTPROTO=none
ONBOOT=yes
TYPE=Ethernet
USERCTL=yes
IPADDR=192.168.40.10
PREFIX=24
GATEWAY=192.168.40.1
DNS1=8.8.8.8
```

---

## Step 3 — Apply the configuration

```bash
sudo systemctl restart network
```

Or reboot the VM :

```bash
sudo reboot
```

---

## Step 4 — Verify

```bash
ip a show eth0
ping 192.168.40.1 -c 4    # ping pfSense gateway
```

Expected output :
```
inet 192.168.40.10/24 brd 192.168.40.255 scope global eth0
```
