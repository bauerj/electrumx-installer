if [ "$VERSION_ID" != "7" ]; then
	warning "Only the latest version (CentOS 7) is officially supported (but this might work)"
fi

function install_compiler {
	yum update
	yum -y install gcc-c++ bzip2
}

function install_script_dependencies {
	yum -y install wget openssl
}

. distributions/base.sh
. distributions/base-systemd.sh
. distributions/base-conda.sh
. distributions/base-compile-rocksdb.sh


function install_leveldb {
	yum -y install libleveldb-dev build-essential
}

function install_git {
	yum -y install git
}

function install_rocksdb_dependencies {
	# /usr/lib is not always included?
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib
	yum -y install snappy snappy-devel zlib zlib-devel bzip2-libs bzip2-devel libgflags-dev cmake make
	_DIR=$(pwd)
	git clone https://github.com/gflags/gflags /tmp/gflags
	cd /tmp/gflags
	mkdir build && cd build
	export CXXFLAGS="-fPIC" && cmake .. && make VERBOSE=1
	make && make install
	cd $_DIR
}