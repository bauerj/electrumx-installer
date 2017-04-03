if [ "$VERSION_ID" != "8" ]; then
	warning "Only the latest version (Jessie) is officially supported (but this might work)"
fi

. distributions/base.sh
. distributions/base-systemd.sh
. distributions/base-debianoid.sh

APT="apt-get"


function add_user {
	adduser --no-create-home --disabled-login --gecos "" electrumx
}

function install_python36 {
	$APT update
	$APT install -y wget bzip2 build-essential gcc
	wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/conda.sh
        bash /tmp/conda.sh -b -p /opt/python
	ln -s /opt/python/bin/python3 /usr/local/bin/python3
}

function install_pyrocksdb {
	$APT install -y libsnappy-dev zlib1g-dev libbz2-dev libgflags-dev
	_DIR=$(pwd)
	# First, install rocksdb
	git clone https://github.com/facebook/rocksdb.git /tmp/rocksdb
	cd /tmp/rocksdb
	# Of course pyrocksdb wouldn't be pyrocksdb if it supported the latest version
	git checkout v4.5.1
	make shared_lib -j 2
	make install-shared INSTALL_PATH=/usr
	python3 -m pip install "Cython>=0.20"
	python3 -m pip install git+git://github.com/stephan-hof/pyrocksdb.git
	cd $_DIR
}

function install_leveldb {
	$APT install -y libleveldb-dev build-essential
}

function install_git {
	$APT install -y git
}

eval "base_$(declare -f install_electrumx)"
function install_electrumx {
	base_install_electrumx
	# We installed to /opt/python, so link it to $PATH
	ln -s /opt/python/bin/electrumx* /usr/local/bin/
}
