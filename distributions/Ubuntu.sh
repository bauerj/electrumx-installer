if [ "$VERSION_ID" != "16.04" ]; then
	_warning "Only the latest LTS version (16.04) is officially supported (but this will probably work)"
fi

. distributions/base.sh
. distributions/base-systemd.sh
. distributions/base-debianoid.sh


function install_python36 {
	$APT update
	$APT install -y software-properties-common || _error "Could not install package" 5
	add-apt-repository -y ppa:jonathonf/python-3.6
	$APT update
	$APT install -y python3.6 python3.6-dev || _error "Could not install package python3.6" 1
	ln -s $(which python3.6) /usr/local/bin/python3
}

function install_rocksdb {
	$APT install -y librocksdb-dev build-essential libsnappy-dev zlib1g-dev libbz2-dev libgflags-dev || _error "Could not install packages" 1
}

function install_leveldb {
	$APT install -y libleveldb-dev || _error "Could not install packages" 1
}
