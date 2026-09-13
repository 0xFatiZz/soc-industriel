# Troubleshooting — DMZ Server

---

## Issue 1 — Guacamole not accessible on port 8080

### Symptom
Guacamole is running (`sudo docker ps`) but not accessible on port 8080.  
`docker ps` shows a random port like `32768` instead of `8080` :

```
0.0.0.0:32768->8080/tcp    guacamole_compose
```

### Cause
The port `8080:8080` line in `docker-compose.yml` is commented out by default :

```yaml
ports:
## enable next line if not using nginx
##  - 8080:8080/tcp
```

### Fix

**Step 1 — Edit docker-compose.yml**

```bash
sudo nano ~/guacamole-docker-compose-master/docker-compose.yml
```

Find the ports section and uncomment the 8080 line :

```yaml
ports:
    - 8080:8080/tcp    # remove the ## at the beginning
```

**Step 2 — Restart the containers**

```bash
cd ~/guacamole-docker-compose-master
sudo docker-compose down
sudo docker-compose up -d
```

**Step 3 — Verify**

```bash
sudo docker ps
```

You should now see :
```
0.0.0.0:8080->8080/tcp    guacamole_compose
```

**Step 4 — Update pfSense rule**

Make sure the pfSense rule allows port `8080` (not the random port) :

```
Source      : 192.168.40.2
Destination : 192.168.35.10
Port        : 8080
Action      : Pass
```

**Step 5 — Access Guacamole**

```
http://192.168.35.10:8080/guacamole
Login    : guacadmin
Password : guacadmin
```

---

## Issue 2 — Guacamole page loads blank (white page)

### Symptom
The URL `http://192.168.35.10:8080/guacamole` loads but shows a blank white page.

### Cause
Internet Explorer does not support Guacamole.

### Fix
Use a modern browser — Firefox or Chrome :

```
https://www.mozilla.org/firefox
https://www.google.com/chrome
```

---

## Issue 3 — Cannot ping DMZ Server from SOC Analyst WS

### Symptom
`ping 192.168.35.10` fails from the Windows VM.

### Cause
Missing pfSense firewall rule allowing SOC → DMZ traffic.

### Fix
Add the following rule in pfSense :

```
Firewall → Rules → SOC → Add
  Action      : Pass
  Protocol    : TCP
  Source      : 192.168.40.2
  Destination : 192.168.35.10
  Port        : 8080
  Description : SOC Analyst → Guacamole DMZ
```

Save → Apply Changes.
