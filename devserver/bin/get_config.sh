#!/bin/bash
usage() {
  echo "Script take minikube config from remote host and prepare it to user"
  echo "Usage: ./get_config.sh <user_name> <host>"
}

if [ "$#" -ne 2 ]; then
    usage;
    exit 1
fi

name=$1
host=$2

CONFIGS_DIR=~/minikube

echo "Copy config and certificates"
mkdir -p ~/minikube/$name/
ssh $host sudo cat /root/.kube/config > $CONFIGS_DIR/$name/config
ssh $host sudo cat /root/.minikube/ca.crt > $CONFIGS_DIR/$name/ca.crt
ssh $host sudo cat /root/.minikube/client.crt > $CONFIGS_DIR/$name/client.crt
ssh $host sudo cat /root/.minikube/client.key > $CONFIGS_DIR/$name/client.key

echo "Prepare config: $CONFIGS_DIR/$name/config"
# mac os hack
sed -e 's|/root/.minikube/||g' $CONFIGS_DIR/$name/config > $CONFIGS_DIR/$name/config.new

mv $CONFIGS_DIR/$name/config.new $CONFIGS_DIR/$name/config

echo "Make archive with config: $CONFIGS_DIR/$name.tar.gz"
tar -czvf $CONFIGS_DIR/$name.tar.gz -C $CONFIGS_DIR/$name/ .
