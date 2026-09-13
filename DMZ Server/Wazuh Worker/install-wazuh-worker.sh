#!/bin/bash
# =============================================================================
# install-wazuh-worker.sh — Wazuh Worker DMZ
# SOC Industriel — Modèle Purdue
#
# Ce script installe Wazuh Manager en mode Worker sur la VM DMZ.
# Le Worker collecte les logs des agents OT et les transmet au Manager SOC.
#
# VM DMZ       : 192.168.35.10
# Wazuh Manager: 192.168.40.10
# Dashboard    : http://192.168.40.10  (login: admin / admin)
# =============================================================================

set -e
set -x

# Forcer le DNS pour eviter les problemes de resolution
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Importer la cle GPG officielle Wazuh
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | sudo gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import

# Donner les bonnes permissions sur le keyring
sudo chmod 644 /usr/share/keyrings/wazuh.gpg

# Ajouter le repo Wazuh 4.x
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | sudo tee /etc/apt/sources.list.d/wazuh.list

# Mettre a jour les paquets
sudo apt update

# Installer Wazuh Manager
sudo apt install wazuh-manager -y

# Activer et demarrer le service
sudo systemctl enable wazuh-manager
sudo systemctl start wazuh-manager

# Verifier que le service tourne
sudo systemctl status wazuh-manager --no-pager | head -5

echo ""
echo "=============================================="
echo "Wazuh Worker installe avec succes !"
echo ""
echo "  VM DMZ        : 192.168.35.10"
echo "  Wazuh Manager : 192.168.40.10"
echo "  Dashboard     : http://192.168.40.10"
echo "  Login         : admin"
echo "  Password      : admin"
echo "=============================================="
