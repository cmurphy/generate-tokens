#!/bin/bash -e

if [ -n "$DEBUG" ]
then
    set -x
fi

usage() {
    echo "./generate-tokens.sh users.csv [--print]"
    echo "CSV file must be in format userid,authprovider"
    echo "By default, result is applied with kubectl to current cluster context. Use --print to print only or pipe to another command."
}

user_list=$1

if [ "$user_list" == "" ]
then
    usage
    exit 1
fi

print_only=$2

tokens=''

while read line
do
    read user provider < <(echo $line | awk -F ',' '{print $1" "$2}')
    if [[ "$user" == "" || "$provider" == "" ]]
    then
        echo "malformed line in $user_list:"
        echo "$line"
        exit 1
    fi
    tokens="$tokens
---
apiVersion: management.cattle.io/v3
kind: Token
metadata:
  name: rancher-fix-$user
  labels:
    cattle.io/bugfix: 'true'
authProvider: $provider
isDerived: false
userId: $user
description: Temporary login token to fix Rancher bug"

done < $user_list

if [ "$print_only" == "" ]
then
    echo "$tokens" | kubectl apply -f -
else
    echo "$tokens"
fi

>&2 echo "To delete tokens, run 'kubectl delete token -l cattle.io/bugfix=true'"
