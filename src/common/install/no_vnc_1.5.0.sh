#!/bin/bash
### every exit != 0 fails the script
set -e

echo "Install noVNC - HTML5 based VNC viewer"
mkdir -p $NO_VNC_HOME/utils/websockify
wget -qO- https://github.com/novnc/noVNC/archive/v1.5.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME
wget -qO- https://github.com/novnc/websockify/archive/v0.11.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify

# Create index.html to forward automatically to vnc.html
ln -s $NO_VNC_HOME/vnc.html $NO_VNC_HOME/index.html