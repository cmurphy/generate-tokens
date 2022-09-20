#!/bin/bash -e

if [ -n "$DEBUG" ]
then
    set -x
fi

usage() {
    echo "./generate-tokens.sh users.csv"
    echo "CSV file must be in format userid,authprovider"
}

user_list=$1

if [ "$user_list" == "" ]
then
    usage
    exit 1
fi

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

echo "$tokens" | kubectl apply -f -

echo "To delete tokens, run 'kubectl delete token -l cattle.io/bugfix=true'"
