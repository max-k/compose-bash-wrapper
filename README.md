# compose-bash-wrapper
Damn simple but useful docker/docker-compose wrapper

## Why compose.sh

### Because :

* You don't have to switch between docker and docker-compose

* You don't have to always specify -d or -ti options

* It makes your docker-compose usage easy and blazing fast

## Documentation

```.bash
$ ./compose.sh -h

compose.sh : Damn simple but useful docker/docker-compose wrapper
Copyright Thomas Sarboni <max-k@post.com> 2016

Usage :
  ./compose.sh [subcommand] [params]

Available subcommands :
  -h   : Print this help message
  help : Print this help message
  up   : Create all needed resources and start all services
  rm   : Delete all (running or not) services containers
  sh   : Run a shell in a running service container
  dead : Run a shell in a non-running service container
  sync : Sync enstadm codebase with running python service container
  *    : Any other subcommand will be forwarded to docker-compose

This wrapper can only be used with 'version 2' docker-compose.yml
So, please use service names instead of container names

To show docker-compose help, please run 'compose.sh --help'

```

## Configuration

There is no default configuration but it is almost usable without it.

You have to fill configuration variables in the file to enable more features.

### Custom prefix for container names

Default docker-compose naming convention will work out of the box

If you named your containers using a custom prefix, you'll have to specify it

```.bash
prefix="customprefix"
```

### Manual code syncronization with a running container

To be able to use sync command, you have to do some extra configuration

* src    : Git root of directory to copy to the container
* subdir : Subdirectory to copy to the container (relative to src) [optional]
* dest   : destination directory to overwrite with subdir
* remote : Remote container to copy to (service name)

```.bash
src="linshare-io-portal"
subdir="modules"
dest="/var/www"
remote="node"
```

## Limitations

* compose.sh cannot sync code to multiple remote containers

