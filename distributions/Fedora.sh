. distributions/base-rhel.sh

export PYTHONUSERBASE=/usr/local/lib/python3.6/site-packages

if [ "$VERSION_ID" != "28" ]; then
        warning "Only the latest version (Fedora 28) is officially supported (but this might work)"
fi

has_rocksdb_binary=1
newer_rocksdb=1

function binary_install_rocksdb {
    dnf -y install redhat-rpm-config python3-devel snappy-devel zlib-devel rocksdb-devel lz4-devel bzip2-devel gflags-devel gcc-c++ gcc || _error "Unable to install rocksdb" 1
}

function binary_uninstall_rocksdb {
    $APT remove  -y rocksdb rocksdb-devel || _error "Could not remove rocksdb" 1
}

