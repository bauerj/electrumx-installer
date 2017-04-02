APT="apt-get"

function add_user {
	adduser --no-create-home --disabled-login --gecos "" electrumx
}

function install_git {
	$APT install -y git
}
