function install_init {
	if [ ! -d /etc/systemd/system ]; then
		error "/etc/systemd/system does not exist. Is systemd installed?"
		exit 8
	fi
	cp /tmp/electrumx/contrib/systemd/electrumx.service /etc/systemd/system/electrumx.service
	cp /tmp/electrumx/contrib/systemd/electrumx.conf /etc/
	if [ $USE_ROCKSDB == 1 ]; then
		echo -e "\nDB_ENGINE=rocksdb" >> /etc/electrumx.conf
	fi
	systemctl daemon-reload
	systemctl enable electrumx
	systemctl status electrumx
	info "Use service electrumx start to start electrumx once it's configured"
}
