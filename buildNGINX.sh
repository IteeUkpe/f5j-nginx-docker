#!/bin/bash

BANNER="NGINX Docker image builder\n\n
This tool builds a NGINX Plus Docker image\n\n
=== Usage:\n\n
$0 [options]\n\n
=== Options:\n\n
-h\t\t\t- This help\n
-t [target image]\t- Docker image name to be created\n
-o [base OS image]\t- base OS image name\n
-i [image type]\t- NGINX image type name\n
-C [file.crt]\t\t- Certificate file to pull packages from the official NGINX repository\n
-K [file.key]\t\t- Key file to pull packages from the official NGINX repository\n
-p \t\t\t- Push Docker image to registry\n
"

BASEGITURL="url = https://github.com/BeF5/f5j-nginx-docker.git"
GITURL=`grep url .git/config`



# Defaults
INVALID_WORKDIR=true
PUSHIMG=false
NGINX_CERT=nginx-repo.crt
NGINX_KEY=nginx-repo.key

# check running directory
if [[ $GITURL =~ $BASEGITURL ]]
then
   INVALID_WORKDIR=false
fi

if "${INVALID_WORKDIR}"
then
   echo "Please run this command root directory of f5j-nginx-docker git repository."
   exit
fi

# check option
while getopts 'ho:i:t:C:K:p' OPTION
do
        case "$OPTION" in
                h)
                        echo -e $BANNER
                        echo "=== Target OS / NGINX image:"
                        echo "|--<<base OS Image>>"
                        echo "|  |--<<NGINX image type>>"
                        find . -type d -name .git -prune -o -type d -maxdepth 2  | sort | sed '2d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g'
                        exit
                ;;
                o)
                        OS_TYPE=$OPTARG
                ;;
                i)
                        IMAGE_TYPE=$OPTARG
                ;;
                t)
                        IMG_NAME=$OPTARG
                ;;
                C)
                        NGINX_CERT=$OPTARG
                ;;
                K)
                        NGINX_KEY=$OPTARG
                ;;
                p)
                        PUSHIMG=true
                ;;
        esac
done


if [ -z "$1" ]
then
        echo -e $BANNER
        exit
fi

if [ -z "${IMG_NAME}" ]
then
        echo "Docker image name is required"
        exit
fi

if [ -z "${OS_TYPE}" ]
then
        echo "base OS Image is required"
        exit
fi

if [ -z "${IMAGE_TYPE}" ]
then
        echo "NGINX image type is required"
        exit
fi

if [ -z "${IMAGE_TYPE}" ]
then
        echo "NGINX image type is required"
        exit
fi

if ([[ "plus" =~ ${IMAGE_TYPE}  ]] && ([ -z "${NGINX_CERT}" ] || [ -z "${NGINX_KEY}" ]))
then
        echo "NGINX certificate and key are required for building NGINX Plus docker images"
        exit
fi

if [ ! -d "${OS_TYPE}/${IMAGE_TYPE}" ]
then
        echo "Specify existing target base OS / NGINX image."
        echo ""
        echo "=== Target OS / NGINX image:"
        echo "|--<<base OS Image>>"
        echo "|  |--<<NGINX image type>>"
        find . -type d -name .git -prune -o -type d  -maxdepth 2 | sort | sed '2d;s/^\.//;s/\/\([^/]*\)$/|--\1/;s/\/[^/|]*/|  /g'
        exit
fi

echo "==> Building NGINX docker image"

if [[ "plus" =~ ${IMAGE_TYPE}  ]] 
then
    DOCKER_BUILDKIT=1 \
    docker build --no-cache \
      -f ${OS_TYPE}/${IMAGE_TYPE}/Dockerfile \
      --secret id=nginx-key,src=$NGINX_KEY --secret id=nginx-crt,src=$NGINX_CERT \
      --build-arg OS_TYPE=${OS_TYPE} \
      --build-arg IMAGE_TYPE=${IMAGE_TYPE} .
else
    DOCKER_BUILDKIT=1 \
    docker build --no-cache \
      -f ${OS_TYPE}/${IMAGE_TYPE}/Dockerfile .
fi

if [ $? != 0 ]
then
    echo "Container Build is Failed."
    exit
fi

echo "==> Building NGINX docker image finished."

echo "==> Pushing NGINX docker image."

if "${PUSHIMG}"
then
   echo "Push docker image."
   docker push $IMG_NAME
fi


if [ $? != 0 ]
then
    echo "Container Image Push is Failed."
    exit
fi

echo "==> Pushing NGINX docker image finished."
