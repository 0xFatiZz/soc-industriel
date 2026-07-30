# Network Configuration Guide — DMZ Server (DMZ Zone)

> **VM:** DMZ Server — 192.168.35.10  
> **Zone:** DMZ (Level 3.5) — dmz-net  
> **Method:** /etc/netplan/

---

## Step 1 — Open the network config file

```bash
sudo nano /etc/netplan/00-installer-config.yaml
```

---

## Step 2 — Replace the content with

```yaml
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 192.168.35.10/24
      routes:
        - to: default
          via: 192.168.35.1
      nameservers:
        addresses: [8.8.8.8]
```

> ⚠️ Replace `enp0s3` with your interface name if different (check with `ip link show`)

---

## Step 3 — Apply the configuration

```bash
sudo netplan apply
```

---

## Step 4 — Verify

```bash
ip a show enp0s3
ping 192.168.35.1 -c 4    # ping pfSense gateway
```

Expected output :
```
inet 192.168.35.10/24 brd 192.168.35.255 scope global enp0s3
```
