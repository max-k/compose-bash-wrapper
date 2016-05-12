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
    echo "  -h    : Print this help message"
    echo "  help  : Print this help message"
    echo "  up    : Create all needed resources and start all services"
    echo "  rm    : Delete all (running or not) services containers"
    echo "  sh    : Run a shell in a running service container"
    echo "  dead  : Run a shell in a non-running service container"
    echo "  sync  : Sync codebase with running service container"
    echo "  logs  : Show container(s) logs and follow them by default"
    echo "  clean : Delete volumes related to current docker-compose"
    echo "  *     : Any other subcommand will be forwarded to docker-compose"
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
function _sh () {
    if [ $# -eq 2 ]; then
        docker exec -ti paristech-${2} /bin/bash
    else
        docker exec -ti paristech-${2} /bin/bash -c "${*:3}"
    fi
}
function _clean () {
    if [ $(./compose.sh ps | wc -l) -ne 2 ]; then
        echo "ERROR : Please shutdown your environment first."
        echo "You can use \`./compose.sh down\` command"
    else
        c=$(docker volume ls -qf dangling=true | grep ^${basedir}_* | wc -l )
        if [ $c -eq 0 ]; then
            echo "Nothing to delete"
            exit 0
        fi
        echo "This volumes will be deleted"
        echo "$(docker volume ls -qf dangling=true | grep ^${basedir}_*)"
        read -r -p "Are you sure ? [y/n] " answer
        case $answer in
            y|Y)
                for volume in $(docker volume ls -qf dangling=true); do
                    echo $volume | grep ^${basedir}_* 2>&1 > /dev/null
                    if [ $? -eq 0 ]; then
                        docker volume rm $volume 2>&1 > /dev/null
                    fi
                done
                echo "Operation completed"
                exit 0 ;;
            *)
                echo "Operation cancelled"
                exit 0 ;;
        esac
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
    sh) _sh $@ ;;
    logs) docker-compose logs -f ${@:2} ;;
    dead) docker-compose run --entrypoint /bin/bash ${2} ;;
    clean) _clean ;;
    sync) _sync ;;
    up) docker-compose up -d ;;
    rm) docker-compose rm -f ${@:2} ;;
    help|-h) _help ;;
    *) _compose $@ ;;
esac
