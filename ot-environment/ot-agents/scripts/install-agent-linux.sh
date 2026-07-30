#!/bin/bash
# =============================================================================
# install-agent-linux.sh — Wazuh Agent Installation (OT VMs)
# Industrial SOC — Purdue Model
#
# Run this script on each OT VM :
#   - Engineering WS  : 192.168.30.10  (agent name: engineering-ws)
#   - ScadaBR         : 192.168.20.10  (agent name: scadabr)
#   - OpenPLC         : 192.168.10.10  (agent name: openplc)
#
# Agents send logs to Wazuh Worker (DMZ) : 192.168.35.10
# Worker forwards logs to Wazuh Manager  : 192.168.40.10
#
# USAGE :
#   sudo bash install-agent-linux.sh <agent-name>
#   Example: sudo bash install-agent-linux.sh engineering-ws
# =============================================================================

set -e

# Agent name passed as argument
AGENT_NAME=$1
WAZUH_WORKER="192.168.35.10"

if [ -z "$AGENT_NAME" ]; then
  echo "Usage: sudo bash install-agent-linux.sh <agent-name>"
  echo "Example: sudo bash install-agent-linux.sh engineering-ws"
  exit 1
fi

echo "=============================================="
echo "  Installing Wazuh Agent : $AGENT_NAME"
echo "  Wazuh Worker (DMZ)     : $WAZUH_WORKER"
echo "=============================================="

# Fix DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Add Wazuh GPG key
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import

# Set correct permissions
sudo chmod 644 /usr/share/keyrings/wazuh.gpg

# Add Wazuh repository
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee /etc/apt/sources.list.d/wazuh.list

# Update packages
sudo apt update

# Install Wazuh agent — pointing to Worker DMZ
sudo WAZUH_MANAGER="$WAZUH_WORKER" \
     WAZUH_AGENT_NAME="$AGENT_NAME" \
     apt install wazuh-agent -y

# Enable and start the agent
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent

# Verify
sudo systemctl status wazuh-agent --no-pager | head -5

echo ""
echo "=============================================="
echo "[✓] Wazuh Agent installed : $AGENT_NAME"
echo ""
echo "  Sending logs to  : $WAZUH_WORKER (DMZ Worker)"
echo "  Forwarded to     : 192.168.40.10 (Manager)"
echo ""
echo "  Verify on Manager :"
echo "  sudo /var/ossec/bin/agent_control -l"
echo "=============================================="
