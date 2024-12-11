#!/bin/bash
### every exit != 0 fails the script
set -e

echo "Install TigerVNC server"
apt-get update
apt-get install -y tigervnc-standalone-server
apt-get clean -y