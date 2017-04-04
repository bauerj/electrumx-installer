function install_rocksdb {
	if ! declare -f install_rocksdb_dependencies > /dev/null; then
		error "install_rocksdb_dependencies needs to be declared in order to use compile-rocksdb/install_rocksdb"
		exit 3
	fi
	install_rocksdb_dependencies
	_DIR=$(pwd)
	# First, install rocksdb
	git clone https://github.com/facebook/rocksdb.git /tmp/rocksdb
	cd /tmp/rocksdb
	# Of course pyrocksdb wouldn't be pyrocksdb if it supported the latest version
	git checkout v4.5.1
	make shared_lib -j 2
	make install-shared INSTALL_PATH=/usr
	cd "$_DIR"
}