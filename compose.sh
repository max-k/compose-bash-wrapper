#! /bin/bash
## Configuration
src=""
subdir=""
dest=""
remote=""
prefix=""
## Prefix calculation
if [ -z "$prefix" ]; then
    basedir="$(basename `pwd`)"
    basedir=${basedir/_/}
    basedir=${basedir/-/}
    basedir=${basedir/ /}
    prefix="${basedir}_"
fi
## Full path calculation
fullsrc="$src"
fulldest="$dest"
[ "${subdir:0:1}" == "/" ] || subdir="/${subdir}"
if [ ! -z "$subdir" ]; then
    fullsrc="${src}${subdir}"
    fulldest="${dest}${subdir}"
fi
## Remote name calculation
len=$(( $(echo $prefix | wc -c) - 1 ))
if [ "${remote:0:$len}" != "$prefix" ]; then
    remote="${prefix}${remote}"
fi
## Functions
function _help () {
    echo ""
    echo "${0:2} : Damn simple but useful docker/docker-compose wrapper"
    echo "Copyright Thomas Sarboni <max-k@post.com> 2016"
    echo ""
    echo "Usage :"
    echo "  $0 [subcommand] [params]"
    echo ""
    echo "Available subcommands :"
    echo "  -h   : Print this help message"
    echo "  help : Print this help message"
    echo "  up   : Create all needed resources and start all services"
    echo "  rm   : Delete all (running or not) services containers"
    echo "  sh   : Run a shell in a running service container"
    echo "  dead : Run a shell in a non-running service container"
    echo "  sync : Sync enstadm codebase with running python service container"
    echo "  *    : Any other subcommand will be forwarded to docker-compose"
    echo ""
    echo "This wrapper can only be used with 'version 2' docker-compose.yml"
    echo "So, please use service names instead of container names"
    echo ""
    echo "To show docker-compose help, please run \`${0:2} --help\`"
    echo ""
    [ -z "$1" ] && exit 1 || exit 0
}
function _sync () {
    format="{{range .Mounts}}{{.Destination}} {{end}}"
    for mountpoint in $(docker inspect --format="$format" $remote); do
        if [ "$mountpoint" == "$fulldest" ]; then
            echo ""
            echo "Codebase already mounted as a volume"
            echo "Synchronisation is not required"
            echo ""
            exit 1
        fi
    done
    if [ -d "${src}/.git" ]; then
        docker cp $fullsrc ${remote}:${fulldest}
        exit 0
    else
        echo ""
        echo "Please download codebase using git submodules first"
        echo ""
        echo "To do that, please run the following commands :"
        echo "  git submodule init"
        echo "  git submodule update"
        echo ""
        exit 1
    fi
}
function _compose () {
    if [ -z "`which docker-compose 2>/dev/null`" ]; then
        echo ""
        echo "docker-compose binary not found"
        echo ""
        echo "Please activate your Python virtualenv"
        echo "and install compose using the following command :"
        echo ""
        echo "  pip install -r requirements.txt"
        echo ""
        echo "More info about virtualenvs can be found here :"
        echo "http://docs.python-guide.org/en/latest/dev/virtualenvs/"
        echo ""
        exit 1
    else
        err=0
        docker-compose $@ 2>.err
        if [ $? -ne 0 ]; then
            err=1
            if [ ! -z "`grep 'No such command' .err`" ]; then
                echo ""
                echo "docker-compose subcommand \`$1\` not found"
                echo "or invalid docker-compose parameters."
                echo ""
                echo "To show docker-compose help, please run \`${0:2} --help\`"
                echo ""
            fi
        fi
        rm .err
        exit $err
    fi
}
## Arguments parsing
[ -z "$1" ] && _help
case $1 in
    sh) docker exec -ti ${prefix}${2} /bin/bash ;;
    dead) docker-compose run --entrypoint /bin/bash ${2} ;;
    sync) _sync ;;
    up) docker-compose up -d ;;
    rm) docker-compose rm -f ${@:2} ;;
    help|-h) _help ;;
    *) _compose $@ ;;
esac
