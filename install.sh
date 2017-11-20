#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0,34m'
NC='\033[0m' # No Color

DB_DIR="/db"
UPDATE_ONLY=0
USE_ROCKSDB=1

# redirect child output
rm /tmp/electrumx-installer-$$.log > /dev/null 2>&1
exec 3>&1 4>&2 2>/tmp/electrumx-installer-$$.log >&2

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-h|--help)
		cat >&4 <<HELP
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
	    _warning "Unknown option $key"
	    exit 12
	    ;;
	esac
	shift # past argument or value
done


function _error {
        if [ -s /tmp/electrumx-installer-$$.log ]; then
	  echo -en "\n---- LOG OUTPUT BELOW ----\n" >&4
	  tail -n 50 /tmp/electrumx-installer-$$.log >&4
	  echo -en "\n---- LOG OUTPUT ABOVE ----\n" >&4
        fi
	printf "\r${RED}ERROR:${NC}   ${1}\n" >&4
	if (( ${2:--1} > -1 )); then
		exit $2
	fi
}

function _warning {
	printf "\r${YELLOW}WARNING:${NC} ${1}\n" >&3
}

function _info {
	printf "\r${BLUE}INFO:${NC}    ${1}\n" >&3
}

function _status {
	echo -en "\r$1" >&3
	printf "%-75s" " " >&3
	echo -en "\n" >&3
	_progress
}

_progress_count=0
_progress_total=8
function _progress {
	_progress_count=$(( $_progress_count + 1 ))
	_pstr="[=======================================================================]"
	_pd=$(( $_progress_count * 73 / $_progress_total ))
	printf "\r%3d.%1d%% %.${_pd}s" $(( $_progress_count * 100 / $_progress_total )) $(( ($_progress_count * 1000 / $_progress_total) % 10 )) $_pstr >&3
}

if [[ $EUID -ne 0 ]]; then
   _error "This script must be run as root (e.g. sudo -H $0)" 1
fi

cd "$(dirname "$0")"

if [ -f /etc/os-release ]; then
	# Load release information
	. /etc/os-release
elif [ -f /etc/issue ]; then
	NAME=$(cat /etc/issue | head -n +1 | awk '{print $1}')
else
	_error "Unable to identify Operating System" 2
fi

NAME=$(echo $NAME | tr -cd '[[:alnum:]]._-')

if [ -f "./distributions/$NAME.sh" ]; then
	. ./distributions/$NAME.sh
else
	_error "'$NAME' is not yet supported" 3
fi

if [ $UPDATE_ONLY == 0 ]; then
	if which electrumx_server.py > /dev/null 2>&1; then
		_error "electrumx is already installed. Use $0 --update to... update." 9
	fi
	_status "Installing installer dependencies"
	install_script_dependencies
	_status "Adding new user for electrumx"
	add_user
	_status "Creating database directory in $DB_DIR"
	create_db_dir $DB_DIR

	if [[ $(python3 -V 2>&1) == *"Python 3.6"* ]] > /dev/null 2>&1; then
		_info "Python 3.6 is already installed."
	else
		_status "Installing Python 3.6"
		install_python36
	fi
	if [[ $(python3 -V 2>&1) == *"Python 3.6"* ]] > /dev/null 2>&1; then
		_info "Python 3.6 successfully installed"
	else
		_error "Unable to install Python 3.6" 4
	fi

	_status "Installing git"
	install_git

	if ! python3 -m pip > /dev/null 2>&1; then
		_progress_total=$(( $_progress_total + 2 ))
		_status "Installing pip"
		install_pip
	fi

	if [ $USE_ROCKSDB == 1 ]; then
		_progress_total=$(( $_progress_total + 2 ))
		_status "Installing RocksDB"
		install_rocksdb
		_status "Installing pyrocksdb"
		install_pyrocksdb
		_status "Checking pyrocksdb installation"
		assert_pyrocksdb
	else
		_status "Installing leveldb"
		install_leveldb
	fi

	_status "Installing electrumx"
	install_electrumx

	_status "Installing init scripts"
	install_init

	_status "Generating TLS certificates"
	generate_cert

	if declare -f package_cleanup > /dev/null; then
		_status "Cleaning up"
		package_cleanup	
	fi
	_info "electrumx has been installed successfully. Edit /etc/electrumx.conf to configure it."
else
	_info "Updating electrumx"
	install_electrumx
        _info "Installed $(python3 -m pip freeze | grep electrumx)"
fi
