# Wazuh Worker Configuration — DMZ Zone (192.168.35.10)

## Prerequisites
- Wazuh Manager installed : `sudo apt install wazuh-manager -y`
- Generate a shared cluster key : `openssl rand -hex 16`
- Keep this key — you will need it on the Manager too

---

## Step 1 — Configure the Cluster

Open the Wazuh config file :
```bash
sudo nano /var/ossec/etc/ossec.conf
```

Find the `<cluster>` section and replace it with :
```xml
<cluster>
  <name>soc-industriel</name>
  <node_name>worker-node</node_name>
  <node_type>worker</node_type>
  <key>160ab01830e3575700349b60220a5f6e</key>         <!-- same key as the Manager -->
  <port>1516</port>
  <bind_addr>0.0.0.0</bind_addr>
  <nodes>
    <node>192.168.40.10</node>     <!-- Wazuh Manager IP -->
  </nodes>
  <hidden>no</hidden>
  <disabled>no</disabled>
</cluster>
```

---

## Step 2 — Configure the Remote (OT agents reception)

In the same file `/var/ossec/etc/ossec.conf`, find the `<remote>` section and replace it with :
```xml
<remote>
  <connection>secure</connection>
  <port>1514</port>
  <protocol>tcp</protocol>
  <allowed-ips>192.168.10.0/24</allowed-ips>  <!-- control-net : OpenPLC        -->
  <allowed-ips>192.168.20.0/24</allowed-ips>  <!-- scada-net   : ScadaBR        -->
  <allowed-ips>192.168.30.0/24</allowed-ips>  <!-- ops-net     : Engineering WS -->
</remote>
```

---

## Step 3 — Restart the service

```bash
sudo systemctl restart wazuh-manager
sudo systemctl status wazuh-manager --no-pager | head -5
```

---

## Step 4 — Verify the cluster connection

```bash
sudo /var/ossec/bin/cluster_control -l
```

Expected output :
```
NAME          TYPE    VERSION  ADDRESS
master-node   master  4.14.5    192.168.40.10
worker-dmz    worker  4.14.5    192.168.35.10
```
