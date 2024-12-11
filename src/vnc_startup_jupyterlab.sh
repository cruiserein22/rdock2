﻿#!/bin/bash### every exit != 0 fails the scriptset -e## print out helphelp (){echo "USAGE:docker run -it -p 6901:6901 -p 5901:5901 consol/<image>:<tag> <option>IMAGES:consol/debian-xfce-vncconsol/rocky-xfce-vncconsol/debian-icewm-vncconsol/rocky-icewm-vncTAGS:latest  stable version of branch 'master'dev     current development version of branch 'dev'OPTIONS:-w, --wait      (default) keeps the UI and the vncserver up until SIGINT or SIGTERM will received-s, --skip      skip the vnc startup and just execute the assigned command.                example: docker run consol/rocky-xfce-vnc --skip bash-d, --debug     enables more detailed startup output                e.g. 'docker run consol/rocky-xfce-vnc --debug bash'-h, --help      print out this helpFore more information see: https://github.com/ConSol/docker-headless-vnc-container"}if [[ $1 =~ -h|--help ]]; then    help    exit 0fi# should also source $STARTUPDIR/generate_container_usersource $HOME/.bashrc# add `--skip` to startup args, to skip the VNC startup procedureif [[ $1 =~ -s|--skip ]]; then    echo -e "\n\n------------------ SKIP VNC STARTUP -----------------"    echo -e "\n\n------------------ EXECUTE COMMAND ------------------"    echo "Executing command: '${@:2}'"    exec "${@:2}"fiif [[ $1 =~ -d|--debug ]]; then    echo -e "\n\n------------------ DEBUG VNC STARTUP -----------------"    export DEBUG=truefi## correct forwarding of shutdown signalcleanup () {    kill -s SIGTERM $!    exit 0}trap cleanup SIGINT SIGTERM## write correct window size to chrome properties$STARTUPDIR/chrome-init.shsource $HOME/.chromium-browser.init## resolve_vnc_connectionVNC_IP=$(hostname -i)## change vnc passwordecho -e "\n------------------ change VNC password  ------------------"# first entry is control, second is view (if only one is valid for both)mkdir -p "$HOME/.vnc"PASSWD_PATH="$HOME/.vnc/passwd"if [[ -f $PASSWD_PATH ]]; then    echo -e "\n---------  purging existing VNC password settings  ---------"    rm -f $PASSWD_PATHfiif [[ $VNC_VIEW_ONLY == "true" ]]; then    echo "start VNC server in VIEW ONLY mode!"    #create random pw to prevent access    echo $(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 20) | vncpasswd -f > $PASSWD_PATHfiecho "$VNC_PW" | vncpasswd -f >> $PASSWD_PATHchmod 600 $PASSWD_PATH## start vncserver and noVNC webclientecho -e "\n------------------ start noVNC  ----------------------------"if [[ $DEBUG == true ]]; then echo "$NO_VNC_HOME/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT"; fi$NO_VNC_HOME/utils/novnc_proxy --vnc localhost:$VNC_PORT --listen $NO_VNC_PORT > $STARTUPDIR/no_vnc_startup.log 2>&1 &PID_SUB=$!#echo -e "\n------------------ start VNC server ------------------------"#echo "remove old vnc locks to be a reattachable container"vncserver -kill $DISPLAY &> $STARTUPDIR/vnc_startup.log \    || rm -rfv /tmp/.X*-lock /tmp/.X11-unix &> $STARTUPDIR/vnc_startup.log \    || echo "no locks present"echo -e "start vncserver with param: VNC_COL_DEPTH=$VNC_COL_DEPTH, VNC_RESOLUTION=$VNC_RESOLUTION\n..."vnc_cmd="vncserver $DISPLAY -depth $VNC_COL_DEPTH -geometry $VNC_RESOLUTION PasswordFile=$HOME/.vnc/passwd --I-KNOW-THIS-IS-INSECURE"if [[ ${VNC_PASSWORDLESS:-} == "true" ]]; then  vnc_cmd="${vnc_cmd} -SecurityTypes None"fiif [[ $DEBUG == true ]]; then echo "$vnc_cmd"; fi$vnc_cmd > $STARTUPDIR/no_vnc_startup.log 2>&1echo -e "start window manager\n..."$HOME/wm_startup.sh &> $STARTUPDIR/wm_startup.log## log connect optionsecho -e "\n\n------------------ VNC environment started ------------------"echo -e "\nVNCSERVER started on DISPLAY= $DISPLAY \n\t=> connect via VNC viewer with $VNC_IP:$VNC_PORT"echo -e "\nnoVNC HTML client started:\n\t=> connect via http://$VNC_IP:$NO_VNC_PORT/?password=...\n"echo -e "Starting jupyterlab at port 8080..."nohup jupyter lab --port 8080 --notebook-dir=/workspace --allow-root --no-browser --ip=0.0.0.0  --NotebookApp.token='' --NotebookApp.password='' &echo -e "Starting Rope..."python /workspace/Rope/Rope.pyif [[ $DEBUG == true ]] || [[ $1 =~ -t|--tail-log ]]; then    echo -e "\n------------------ $HOME/.vnc/*$DISPLAY.log ------------------"    # if option `-t` or `--tail-log` block the execution and tail the VNC log    tail -f $STARTUPDIR/*.log $HOME/.vnc/*$DISPLAY.logfiif [ -z "$1" ] || [[ $1 =~ -w|--wait ]]; then    wait $PID_SUBelse    # unknown option ==> call command    echo -e "\n\n------------------ EXECUTE COMMAND ------------------"    echo "Executing command: '$@'"    exec "$@"fi