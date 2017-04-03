#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0,34m'
NC='\033[0m' # No Color

DB_DIR="/db"
UPDATE_ONLY=0
USE_ROCKSDB=1

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-h|--help)
		cat <<HELP
Usage: install.sh [OPTIONS]

Install electrumx.

 -h --help   Show this help
 -d --dbdir  Set database directory (default: /db/)
 --update    Update previously installed version
 --leveldb   Use LevelDB instead of RocksDB
HELP
		exit 0
		;;
	    -d|--dbdir)
	    DB_DIR="$2"
	    shift # past argument
	    ;;
	    --update)
	    UPDATE_ONLY=1
	    ;;
	    --leveldb)
	    USE_ROCKSDB=0
	    ;;
	    *)
	    warning "Unknown option $key"
	    exit 12
	    ;;
	esac
	shift # past argument or value
done


function error {
	printf "${RED}ERROR:${NC}   ${1}\n" 1>&2
}

function warning {
	printf "${YELLOW}WARNING:${NC} ${1}\n" 1>&2
}

function info {
	printf "${BLUE}INFO:${NC}    ${1}\n" 1>&2
}

if [[ $EUID -ne 0 ]]; then
   error "This script must be run as root (e.g. sudo -H $0)"
   exit 1
fi

cd "$(dirname "$0")"

if [ -f /etc/os-release ]; then
	# Load release information
	. /etc/os-release
elif [ -f /etc/issue ]; then
	NAME=$(cat /etc/issue | head -n +1 | awk '{print $1}')
else
	error "Unable to identify Operating System"
	exit 2
fi

NAME=$(echo $NAME | tr -cd '[[:alnum:]]._-')

if [ -f "./distributions/$NAME.sh" ]; then
	. ./distributions/$NAME.sh
else
	error "'$NAME' is not yet supported"
	exit 3
fi

if [ $UPDATE_ONLY == 0 ]; then
	if which electrumx_server.py > /dev/null 2>&1; then
		error "electrumx is already installed"
		exit 9
	fi
	info "Adding new user for electrumx"
	add_user
	info "Creating database directory in $DB_DIR"
	create_db_dir $DB_DIR

	if [[ $(python3 -V 2>&1) == *"Python 3.6"* ]] > /dev/null 2>&1; then
		info "Python 3.6 is already installed."
	else
		info "Installing Python 3.6"
		install_python36
	fi
	if [[ $(python3 -V 2>&1) == *"Python 3.6"* ]] > /dev/null 2>&1; then
		info "Python 3.6 successfully installed"
	else
		error "Unable to install Python 3.6"
		exit 4
	fi

	install_git

	if ! python3 -m pip > /dev/null 2>&1; then
		install_pip
	fi

	if [ $USE_ROCKSDB == 1 ]; then
		install_pyrocksdb
		assert_pyrocksdb
	else
		install_leveldb
	fi

	install_electrumx

	install_init
	cat <<MEME
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
░░░░░░░▄▄▀▀▀▀▀▀▀▀▀▀▄▄█▄░░░░▄░░░░█░░░░░░░
░░░░░░█▀░░░░░░░░░░░░░▀▀█▄░░░▀░░░░░░░░░▄░
░░░░▄▀░░░░░░░░░░░░░░░░░▀██░░░▄▀▀▀▄▄░░▀░░
░░▄█▀▄█▀▀▀▀▄░░░░░░▄▀▀█▄░▀█▄░░█▄░░░▀█░░░░
░▄█░▄▀░░▄▄▄░█░░░▄▀▄█▄░▀█░░█▄░░▀█░░░░█░░░
▄█░░█░░░▀▀▀░█░░▄█░▀▀▀░░█░░░█▄░░█░░░░█░░░
██░░░▀▄░░░▄█▀░░░▀▄▄▄▄▄█▀░░░▀█░░█▄░░░█░░░
██░░░░░▀▀▀░░░░░░░░░░░░░░░░░░█░▄█░░░░█░░░
██░░░░░░░░░░░░░░░░░░░░░█░░░░██▀░░░░█▄░░░
██░░░░░░░░░░░░░░░░░░░░░█░░░░█░░░░░░░▀▀█▄
██░░░░░░░░░░░░░░░░░░░░█░░░░░█░░░░░░░▄▄██
░██░░░░░░░░░░░░░░░░░░▄▀░░░░░█░░░░░░░▀▀█▄
░▀█░░░░░░█░░░░░░░░░▄█▀░░░░░░█░░░░░░░▄▄██
░▄██▄░░░░░▀▀▀▄▄▄▄▀▀░░░░░░░░░█░░░░░░░▀▀█▄
░░▀▀▀▀░░░░░░░░░░░░░░░░░░░░░░█▄▄▄▄▄▄▄▄▄██
░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░
MEME
	info "electrumx has been installed successfully. Edit /etc/electrumx.conf to configure it."
else
	info "Updating electrumx"
	install_electrumx
fi
