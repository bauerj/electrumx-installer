if [ "$VERSION_ID" != "8" ]; then
	_warning "Only the latest version (Jessie) is officially supported (but this might work)"
fi

. distributions/base.sh
. distributions/base-systemd.sh
. distributions/base-debianoid.sh
. distributions/base-compile-rocksdb.sh
. distributions/base-conda.sh

APT="apt-get"

function install_leveldb {
	$APT install -y libleveldb-dev build-essential
}