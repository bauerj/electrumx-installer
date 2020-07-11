#!/bin/bash

RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0,34m'
NC='\033[0m' # No Color

DB_DIR="/db"
UPDATE_ONLY=0
UPDATE_PYTHON=0
VERBOSE=0
USE_ROCKSDB=1
ELECTRUMX_GIT_URL="https://github.com/spesmilo/electrumx"
ELECTRUMX_GIT_BRANCH=""

installer=$(realpath $0)

cd "$(dirname "$0")"

# Self-update
if which git > /dev/null 2>&1; then
    _version_now=$(git rev-parse HEAD)
    git pull > /dev/null 2>&1
    if [ $_version_now != $(git rev-parse HEAD) ]; then
        echo "Updated installer."
        exec $installer "$@"
    fi
fi

while [[ $# -gt 0 ]]; do
	key="$1"
	case $key in
		-h|--help)
		cat >&2 <<HELP
Usage: install.sh [OPTIONS]

Install electrumx.

 -h --help                     Show this help
 -v --verbose				   Enable verbose logging
 -d --dbdir dir                Set database directory (default: /db/)
 --update                      Update previously installed version
 --update-python			   Install Python 3.7 and use with electrumx (doesn't remove system installation of Python 3)
 --leveldb                     Use LevelDB instead of RocksDB
--electrumx-git-url url        Install ElectrumX from this URL instead
--electrumx-git-branch branch  Install specific branch of ElectrumX repository
HELP
		exit 0
		;;
	    -d|--dbdir)
	    DB_DIR="$2"
	    shift # past argument
	    ;;
		-v|--verbose)
		VERBOSE=1
		;;
	    --update)
	    UPDATE_ONLY=1
	    ;;
		--update-python)
	    UPDATE_PYTHON=1
	    ;;
	    --leveldb)
	    USE_ROCKSDB=0
	    ;;
		--electrumx-git-url)
		ELECTRUMX_GIT_URL="$2"
		shift
		;;
		--electrumx-git-branch)
		ELECTRUMX_GIT_BRANCH="$2"
		shift
		;;
	    *)
	    echo "WARNING: Unknown option $key" >&2
	    exit 12
	    ;;
	esac
	shift # past argument or value
done

# redirect child output
echo "" > /tmp/electrumx-installer-$$.log
exec 3>&1 4>&2 2>/tmp/electrumx-installer-$$.log >&2

if [ $VERBOSE == 1 ]; then
	tail -f /tmp/electrumx-installer-$$.log >&4 &
fi


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

rocksdb_compile=1

if [[ $EUID -ne 0 ]]; then
   _error "This script must be run as root (e.g. sudo -H $0)" 1
fi

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

python=""

for _python in python3 python3.7; do
	if which $_python; then
	python=$_python
	fi
done

if [ $UPDATE_ONLY == 0 ] || [ $UPDATE_PYTHON == 1 ]; then
	if which electrumx_server > /dev/null 2>&1 && [ $UPDATE_PYTHON == 0 ]; then
		_error "electrumx is already installed. Use $0 --update to... update." 9
	fi
	_status "Installing installer dependencies"
	install_script_dependencies
	_status "Adding new user for electrumx"
	add_user
	_status "Creating database directory in $DB_DIR"
	create_db_dir $DB_DIR

	if [[ $($python -V 2>&1) == *"Python 3.6"* ]] > /dev/null 2>&1 && [ $UPDATE_PYTHON == 0 ]; then
		_info "Python 3.6 is already installed."
	elif [[ $($python -V 2>&1) == *"Python 3.7"* ]] > /dev/null 2>&1; then
		_info "Python 3.7 is already installed."
	else
		_status "Installing Python 3.7"
		python=python3.7
		install_python37
		if [[ $($python -V 2>&1) == *"Python 3.7"* ]] > /dev/null 2>&1; then
			_info "Python 3.7 successfully installed"
		else
			_error "Unable to install Python 3.7" 4
		fi
	fi
	

	_status "Installing git"
	install_git

	if ! $python -m pip > /dev/null 2>&1; then
		_progress_total=$(( $_progress_total + 1 ))
		_status "Installing pip"
		install_pip
	fi

	if [ $USE_ROCKSDB == 1 ]; then
	    _progress_total=$(( $_progress_total + 3 ))
        _status "Installing RocksDB"
        if [ ! -z $has_rocksdb_binary ]; then
            binary_install_rocksdb
        else
            install_rocksdb
        fi
            if [ -z $newer_rocksdb ]; then
			    _status "Installing pyrocksdb"
			install_pyrocksdb
		else
			 _status "Installing python_rocksdb"
			install_python_rocksdb
		fi
		_status "Checking pyrocksdb installation"
		if [ ! check_pyrocksdb ]; then
            if [ ! -z $has_rocksdb_binary ]; then
                _status "binary rocksdb doesn't work - compiling instead"
                binary_uninstall_rocksdb
                install_rocksdb
                if [ ! check_pyrocksdb ]; then
                    _error "pyrocksdb installation still doesn't work" 7
                fi
            else
                _error "pyrocksdb installation doesn't work" 6
            fi
		fi
	else
		_status "Installing leveldb"
		install_leveldb
	fi

	_status "Installing electrumx"
	install_electrumx

	if [ $UPDATE_PYTHON == 0 ]; then

		_status "Installing init scripts"
		install_init

		_status "Generating TLS certificates"
		generate_cert

	fi

	if declare -f package_cleanup > /dev/null; then
		_status "Cleaning up"
		package_cleanup	
	fi
	_info "electrumx has been installed successfully. Edit /etc/electrumx.conf to configure it."
else
	_info "Updating electrumx"
	i=0
	while $python -m pip show electrumx; do
	    $python -m pip uninstall -y electrumx || true
	    ((i++))
	    if "$i" -gt 5; then
	        break
	    fi
	done
	if grep '/usr/local/bin/electrumx_server.py' /etc/systemd/system/electrumx.service; then
	    _info "Updating pre-1.5 systemd configuration to new binary names"
		sed -i -- 's/_server.py/_server/g' /etc/systemd/system/electrumx.service
		systemctl daemon-reload
	fi
	install_electrumx
        _info "Installed $($python -m pip freeze | grep -i electrumx)"
fi
