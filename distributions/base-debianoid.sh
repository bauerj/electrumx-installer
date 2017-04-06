APT="apt-get"

function install_git {
	$APT install -y git
}

function install_script_dependencies {
	$APT update
	$APT install -y openssl wget
}

function install_rocksdb_dependencies {
	$APT install -y libsnappy-dev zlib1g-dev libbz2-dev libgflags-dev
}

function install_compiler {
	$APT update
	$APT install -y bzip2 build-essential gcc
}