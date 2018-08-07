# Adding new distributions
This is the procedure to add a new distribution:
## Create a file in `distributions/`
The file name must contain the distribution name followed by `.sh`. The installer uses either the `NAME` variable from `/etc/os-release`
if that file exists or the first word from `/etc/issue`. 
## Implement the functions
You need to define the following functions in your distribution file:
- **add_user**: Create a user called `electrumx`
- **install_$python7**: Install Python 3.7. The first `$python` in `$PATH` should resolve to it.
- **install_git**: Install git
- **install_pyrocksdb**: Install pyrocksdb.
- **install_leveldb**: Install libleveldb and its development headers
- **install_init**: Integrate electrumx into the init system and enable it (if necessary).
- **install_script_dependencies**: Install wget and openssl (if available).

The following functions also need to be defined, but you can source them from `base.sh`:
- create_db_dir(db): Create the database directory and change ownership to the electrumx user
- assert_pyrocksdb: Should exit if rocksdb can't be imported
- install_pip: Install pip to Python 3.6. Only necessary if the installed version doesn't already contain pip.
- install_electrumx: Install electrumx to `/usr/local/bin`.

You can also source some functions from the `base_*.sh` files. For example, Ubuntu sources `install_init` from `base_systemd.sh`
and `install_git` from `base_debianoid.sh`.
## Add the distribution to the travis build matrix.
`.travis.yml` contains the CI build matrix (a list called `env`). Look for your distribution on [Docker Hub](https://hub.docker.com/)
and add the image to the build matrix.
