# Contains functions that should work on all POSIX-compliant systems
function create_db_dir {
	mkdir -p $1
	chown electrumx:electrumx $1
}

function check_pyrocksdb {
    python3 -B -c "import rocksdb"
}

function install_electrumx {
	_DIR=$(pwd)
        python3 -m pip install multidict || true
	rm -rf "/tmp/electrumx/"
	git clone $ELECTRUMX_GIT_URL /tmp/electrumx
	cd /tmp/electrumx
        git checkout $ELECTRUMX_GIT_BRANCH
	if [ $USE_ROCKSDB == 1 ]; then
		# We don't necessarily want to install plyvel
		sed -i "s/'plyvel',//" setup.py
	fi
	python3 setup.py install > /dev/null 2>&1
	if ! python3 setup.py install; then
		_error "Unable to install electrumx" 7
	fi
	cd $_DIR
}

function install_pip {
	wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
	python3 /tmp/get-pip.py
	rm /tmp/get-pip.py
}

function install_pyrocksdb {
	python3 -m pip install "Cython>=0.20"
	python3 -m pip install git+git://github.com/stephan-hof/pyrocksdb.git || _error "Could not install pyrocksdb" 1
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
