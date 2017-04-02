# electrumx-installer
A script to automate the installation of electrumx 🤖

Installing electrumx isn't really straight-forward (yet). You have to install the latest version of Python and various dependencies for
one of the database engines. Then you have to integrate electrumx into your init system.

`electrumx-installer` simplifies this process to running a single command. All that's left to do for you
is to customise the configuration.

## Usage
Clone the repository and run `install.sh` as root:

    git clone https://github.com/bauerj/electrumx-installer
    cd electrumx-installer
    sudo -H ./install.sh

See `install.sh -h` for command line options.
     
## Operating System Compatibility

The following operating systems are officially supported and automatically being tested against:

| OS | Status |
|----------|---|
| Debian Jessie | ![debian](https://badges.herokuapp.com/travis/bauerj/electrumx-installer?env=IMAGE=%22debian:8%22&label=debian:8) |
| Ubuntu 16.04 | ![ubuntu](https://badges.herokuapp.com/travis/bauerj/electrumx-installer?env=IMAGE=%22ubuntu:16.04%22&label=ubuntu:16.04) |

More will follow.
