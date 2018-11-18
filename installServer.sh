#!/bin/bash
me="$(cd $(dirname $BASH_SOURCE) && pwd)"
echo "me: $me"
cd "$me"

if (($EUID!=0));then
    echo "Need run as root!"
    exit 1
fi

if ! command -v python >/dev/null 2>&1;then
    echo "Need python!"
    exit 1
fi

#variable
DEST_BIN_DIR=/usr/local/bin

#soft link to /usr/local/bin
ln -sf $(pwd)/mujson_mgr.py $DEST_BIN_DIR

if ! ls /usr/local/lib/*libsodium* >/dev/null 2>&1;then
    read -p "install chacha20 library? [Y/n] " cc
    if [[ "$cc" != [nN] ]];then
        bash ./libsodium.sh
    fi
fi

#create service
read -p "install ssr service(auto boot) (need systemd)? [Y/n] " ssr
if [[ "$ssr" != [nN] ]];then
    #install tmux
    if command -v apt-get >/dev/null 2>&1;then
        apt-get install -y tmux
    elif command -v yum >/dev/null 2>&1;then
        yum install -y tmux
    fi

    if ! command -v tmux >/dev/null 2>&1;then
        echo "Need tmux!"
        exit 1
    fi

    cp ssr.service /etc/systemd/system
    systemctl daemon-reload
    systemctl enable ssr.service
    systemctl start ssr.service
    echo "use mujson_mgr.py to add user."
fi



