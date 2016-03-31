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

To show docker-compose help, please run `compose.sh --help`
```

## Limitations

* compose.sh cannot sync code to multiple remote containers

