#!/bin/bash
### every exit != 0 fails the script
set -e

echo "Install Firefox"
apt-get update 
apt-get install -y firefox
apt-get clean -y

# Prepare Window Manager Session
echo "Install minimal window manager"
apt-get install -y icewm
apt-get clean -y

# Overwrite IceWM configuration
mkdir -p /root/.icewm/
cat >> /root/.icewm/config << END
TaskBarShowWorkspaces=0
TaskBarShowAllWindows=0
TaskBarShowClock=0
TaskBarShowMailBoxStatus=0
TaskBarShowCPUStatus=0
TaskBarShowWindowListMenu=0
TaskBarShowAPMStatus=0
TaskBarShowNetStatus=0
END

# Disable screensaver and power management
cat >> /root/.icewm/startup << END
#!/bin/bash
xset -dpms &
xset s noblank &
xset s off &
END

chmod +x /root/.icewm/startup