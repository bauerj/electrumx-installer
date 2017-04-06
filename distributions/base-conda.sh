# This should be sourced after base.sh!

eval "base_$(declare -f install_electrumx)"
function install_electrumx {
	base_install_electrumx
	# We installed to /opt/python, so link it to $PATH
	ln -s /opt/python/bin/electrumx* /usr/local/bin/
}

function install_python36 {
	if ! declare -f install_compiler > /dev/null; then
		_error "install_compiler needs to be declared in order to use conda/install_python36" 3
	fi
	install_compiler
	wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/conda.sh || _error "while getting conda" 1
    bash /tmp/conda.sh -b -p /opt/python
	ln -s /opt/python/bin/python3 /usr/local/bin/python3
}