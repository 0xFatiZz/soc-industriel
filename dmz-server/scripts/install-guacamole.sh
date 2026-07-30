#!/bin/bash
# =============================================================================
# install-guacamole.sh — Guacamole Jump Server DMZ
# SOC Industriel — Modèle Purdue
#
# Ce script installe Apache Guacamole via Docker sur la VM DMZ.
# Guacamole sert de Jump Server — point d acces unique vers les VMs OT
# via RDP et SSH depuis le navigateur web.
#
# VM DMZ      : 192.168.35.10
# URL         : http://192.168.35.10:8080/guacamole
# Login       : guacadmin
# Password    : guacadmin  
#
# VMs OT accessibles via Guacamole :
#   - Engineering WS : 192.168.30.10 (RDP)
#   - ScadaBR        : 192.168.20.10 (RDP/SSH)
#   - OpenPLC        : 192.168.10.10 (SSH)
# =============================================================================

set -e
set -x

# Installer Docker et les outils necessaires
sudo apt update
sudo apt install -y docker.io docker-compose wget tar

# Activer et demarrer Docker
sudo systemctl enable docker
sudo systemctl start docker

# Telecharger Guacamole Docker Compose depuis GitHub
wget https://github.com/boschkundendienst/guacamole-docker-compose/archive/refs/heads/master.tar.gz

# Extraire l archive
tar -xvf master.tar.gz

# Entrer dans le dossier
cd guacamole-docker-compose-master

# Preparer Guacamole (genere les certs SSL et la config initiale)
sudo ./prepare.sh

# Demarrer tous les conteneurs en arriere-plan
# Conteneurs : guacamole, guacd, nginx, postgres
sudo docker-compose up -d

# Verifier que les conteneurs sont bien lances
sudo docker ps

echo ""
echo "=============================================="
echo " Guacamole installe avec succes !"
echo ""
echo "  URL      : http://192.168.35.10:8080/guacamole"
echo "  Login    : guacadmin"
echo "  Password : guacadmin"
echo "=============================================="
