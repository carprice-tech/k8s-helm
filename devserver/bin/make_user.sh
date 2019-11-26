#!/bin/bash

user=$1
templates=$2

rm -f devserver/users/${user}_*

echo "" > devserver/users/${user}_empty.yaml

for template in $templates; do
  helm template devserver/users_charts/$template/ -f devserver/users_configs/$user.yaml > devserver/users/${user}_${template}.yaml
done;
