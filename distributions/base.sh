# Contains functions that should work on all POSIX-compliant systems
function create_db_dir {
	info "Creating database directory $1"
	mkdir $1
	chown electrumx:electrumx $1
}

function assert_pyrocksdb {
	if ! python3 -B -c "import rocksdb"; then
		error "pyrocksdb installation doesn't work"
		exit 6
	fi
}

function install_electrumx {
	_DIR=$(pwd)
	rm -rf "/tmp/electrumx/"
	git clone https://github.com/kyuupichan/electrumx /tmp/electrumx
	cd /tmp/electrumx
	if [ $USE_ROCKSDB == 1 ]; then
		# We don't necessarily want to install plyvel
		sed -i "s/'plyvel',//" setup.py
	fi
	python3 setup.py install > /dev/null 2>&1
	if ! python3 setup.py install; then
		error "Unable to install electrumx"
		exit 7
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
	python3 -m pip install git+git://github.com/stephan-hof/pyrocksdb.git
}

function add_user {
	useradd electrumx
}