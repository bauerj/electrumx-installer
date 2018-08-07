# Contains functions that should work on all POSIX-compliant systems
function create_db_dir {
	mkdir -p $1
	chown electrumx:electrumx $1
}

function check_pyrocksdb {
    $python -B -c "import rocksdb"
}

function install_electrumx {
	_DIR=$(pwd)
	rm -rf "/tmp/electrumx/"
	git clone $ELECTRUMX_GIT_URL /tmp/electrumx
	cd /tmp/electrumx
	if [ -z "$ELECTRUMX_GIT_BRANCH" ]; then
		git checkout $ELECTRUMX_GIT_BRANCH
	else
		git checkout $(git describe --tags)
	fi
	if [ $USE_ROCKSDB == 1 ]; then
		# We don't necessarily want to install plyvel
		sed -i "s/'plyvel',//" setup.py
	fi
	if [ "$python" != "python3" ]; then
		sed -i "s:usr/bin/env python3:usr/bin/env python3.7:" electrumx_rpc
		sed -i "s:usr/bin/env python3:usr/bin/env python3.7:" electrumx_server
	fi
	$python -m pip install . --upgrade > /dev/null 2>&1
	if ! $python -m pip install . --upgrade; then
		_error "Unable to install electrumx" 7
	fi
	cd $_DIR
}

function install_pip {
	wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
	$python /tmp/get-pip.py
	rm /tmp/get-pip.py
	if $python -m pip > /dev/null 2>&1; then
		_info "Installed pip to $python"
	else
		_error "Unable to install pip"
	fi
}

function install_pyrocksdb {
	$python -m pip install "Cython>=0.20"
	$python -m pip install git+git://github.com/stephan-hof/pyrocksdb.git || _error "Could not install pyrocksdb" 1
}

function install_python_rocksdb {
    $python -m pip install "Cython>=0.20"
	$python -m pip install python-rocksdb || _error "Could not install python_rocksdb" 1
}

function add_user {
	useradd electrumx
	id -u electrumx || _error "Could not add user account" 1
}

function generate_cert {
	if ! which openssl > /dev/null 2>&1; then
		_info "OpenSSL not found. Skipping certificates.."
		return
	fi
	_DIR=$(pwd)
	mkdir -p /etc/electrumx/
	cd /etc/electrumx
	openssl genrsa -des3 -passout pass:xxxx -out server.pass.key 2048
	openssl rsa -passin pass:xxxx -in server.pass.key -out server.key
	rm server.pass.key
	openssl req -new -key server.key -batch -out server.csr
	openssl x509 -req -days 1825 -in server.csr -signkey server.key -out server.crt
	rm server.csr
	chown electrumx:electrumx /etc/electrumx -R
	chmod 600 /etc/electrumx/server*
	cd $_DIR
	echo -e "\nSSL_CERTFILE=/etc/electrumx/server.crt" >> /etc/electrumx.conf
	echo "SSL_KEYFILE=/etc/electrumx/server.key" >> /etc/electrumx.conf
        echo "TCP_PORT=50001" >> /etc/electrumx.conf
        echo "SSL_PORT=50002" >> /etc/electrumx.conf
        echo -e "# Listen on all interfaces:\nHOST=" >> /etc/electrumx.conf
}

function ver { printf "%03d%03d%03d%03d" $(echo "$1" | tr '.' ' '); }
