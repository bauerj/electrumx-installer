function install_rocksdb {
	if ! declare -f install_rocksdb_dependencies > /dev/null; then
		_error "install_rocksdb_dependencies needs to be declared in order to use compile-rocksdb/install_rocksdb" 3
	fi
	install_rocksdb_dependencies
	_DIR=$(pwd)
	# First, install rocksdb
	_info "Loading RocksDB source"
	git clone https://github.com/facebook/rocksdb.git /tmp/rocksdb
	cd /tmp/rocksdb
	# Of course pyrocksdb wouldn't be pyrocksdb if it supported the latest version
	git checkout v4.5.1
	_info "Compiling RocksDB... This will take a while."
	make shared_lib -j 2 || _error "Could not compile rocksdb" 1
	make install-shared INSTALL_PATH=/usr || _error "Could not install rocksdb" 1
	cd "$_DIR"
}