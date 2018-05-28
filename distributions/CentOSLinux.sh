if [ "$VERSION_ID" != "7" ]; then
        warning "Only the latest version (CentOS 7) is officially supported (but this might work)"
fi

. distributions/base-rhel.sh
