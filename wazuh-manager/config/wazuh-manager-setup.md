# Wazuh Manager Configuration Guide (SOC Zone)

> **VM:** Wazuh Manager — 192.168.40.10  
> **Zone:** SOC/IT (Level 4) — soc-net  
> **Installed via:** Wazuh OVA

---

## Step 1 — Open the config file

```bash
sudo nano /var/ossec/etc/ossec.conf
```

---

## Step 2 — Configure the Cluster (Master)

Find the `<cluster>` section and replace it with :

```xml
<cluster>
  <name>soc-industriel</name>
  <node_name>master-node</node_name>
  <node_type>master</node_type>
  <key>160ab01830e3575700349b60220a5f6e</key>         <!-- same key as the Worker -->
  <port>1516</port>
  <bind_addr>0.0.0.0</bind_addr>
  <nodes>
    <node>192.168.40.10</node>     <!-- this node (Manager IP) -->
  </nodes>
  <hidden>no</hidden>
  <disabled>no</disabled>       <!-- make it yes -->
</cluster>
```

> ⚠️ The `<key>` must be **identical** on both Manager and Worker.  
> Generate one with : `openssl rand -hex 16`

---

## Step 3 — Restart the service

```bash
sudo systemctl restart wazuh-manager
sudo systemctl status wazuh-manager --no-pager | head -5
```

---

## Step 4 — Verify the cluster

```bash
sudo /var/ossec/bin/cluster_control -l
```

Expected output :
```
NAME          TYPE    VERSION  ADDRESS
master-node   master  4.14.5    192.168.40.10
worker-dmz    worker  4.14.5    192.168.35.10
```
