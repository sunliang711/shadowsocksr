#!/bin/bash
root="$(cd $(dirname $BASH_SOURCE) && pwd)"
cd "$root"

if (($EUID!=0));then
    echo "Need run as root!"
    exit 1
fi

usage(){
    cat<<-EOF
	Usage: $(basename $0) CMD
	CMD:
		install
		uninstall
	EOF
    exit 0
}

#variable
DEST_BIN_DIR=/usr/local/bin

install(){
    if ! command -v python >/dev/null 2>&1;then
        echo "Need python!"
        exit 1
    fi

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

        sed "s|ROOT|$root|" ssr.service >/etc/systemd/system/ssr.service
        systemctl daemon-reload
        systemctl enable ssr.service
        systemctl start ssr.service
        echo "use mujson_mgr.py to add user."
    fi

    read -p "enable BBR? [Y/n]" bbr
    if [[ "$bbr" != [nN] ]];then
        bash enableBBR.sh
    fi
}

uninstall(){
    rm $DEST_BIN_DIR/mujson_mgr.py
    systemctl stop ssr
    rm /etc/systemd/system/ssr.service
    systemctl daemon-reload
}

cmd=$1

case $cmd in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    *)
        usage
        ;;
esac
