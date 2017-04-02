if [ "$VERSION_ID" != "16.04" ]; then
	warning "Only the latest LTS version (16.04) is officially supported (but this will probably work)"
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
	$APT install -y software-properties-common wget
	add-apt-repository -y ppa:jonathonf/python-3.6
	$APT update
	$APT install -y python3.6 python3.6-dev
	ln -s $(which python3.6) /usr/local/bin/python3
}

function install_pyrocksdb {
	$APT install -y libsnappy-dev zlib1g-dev libbz2-dev libgflags-dev librocksdb-dev build-essential
	python3 -m pip install "Cython>=0.20"
	python3 -m pip install git+git://github.com/stephan-hof/pyrocksdb.git
}

function install_leveldb {
	$APT install -y libleveldb-dev build-essential
}

function install_git {
	$APT install -y git
}
