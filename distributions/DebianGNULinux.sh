if [ "$VERSION_ID" != "8" ]; then
	warning "Only the latest version (Jessie) is officially supported (but this might work)"
fi

. distributions/base.sh
. distributions/base-systemd.sh
. distributions/base-debianoid.sh
. distributions/base-compile-rocksdb.sh
. distributions/base-conda.sh

APT="apt-get"

function add_user {
	adduser --no-create-home --disabled-login --gecos "" electrumx
}


function install_leveldb {
	$APT install -y libleveldb-dev build-essential
}