#!/bin/bash

if [ -z "$OS_USERNAME" ]; then
    echo "OS_USERNAME is not set."
    exit 2
fi

if [ -z "$OS_AUTH_URL" ]; then
    echo "OS_AUTH_URL is not set."
    exit 2
fi

if [ -z "$OS_USER_DOMAIN_NAME" ]; then
    echo "OS_USER_DOMAIN_NAME is not set."
    exit 2
fi

if [ -z "$OS_DOMAIN_NAME" ]; then
    echo "OS_DOMAIN_NAME is not set."
    exit 2
fi


if [ -z "$OS_PASSWORD" ]; then
    echo "OS_PASSWORD is not set."
    exit 2
fi


if [ -z "$NEW_DOMAIN_NAME" ]; then
    echo "NEW_DOMAIN_NAME is not set."
    exit 2
fi

if [ -z "$DOMAIN_ADMIN" ]; then
    echo "DOMAIN_ADMIN is not set."
    exit 2
fi

OS_IDENTITY_API_VERSION=3

# Generate session token
# Authenticate cloud admin
OS_TOKEN=$(openstack token issue --os-username $OS_USERNAME -f value -c id)

STDOUT=$(openstack domain list | grep $NEW_DOMAIN_NAME)

if [[ ! "$STDOUT" =~ "" ]]; then
    openstack domain create $NEW_DOMAIN_NAME --description "Domain created for $NEW_DOMAIN_NAME"
fi

DOMAIN_ID=$(openstack domain show $NEW_DOMAIN_NAME -f value -c id)

curl -sX PATCH $OS_AUTH_URL/domains/$DOMAIN_ID/config -H "X-Auth-Token: $OS_TOKEN" -H "Content-type: application/json" -d'@CloudAdmin/DomainCreation/Domain.json' | jq .

DOMAIN_ADMIN_ID=`curl -sX GET -H "X-Auth-Token: ${OS_TOKEN}" "${OS_AUTH_URL}/users?domain_id=${DOMAIN_ID}" | jq .users | jq "map(select(.name==\"$DOMAIN_ADMIN\")) | .[].id" | tr -d '"'`

openstack role add --domain $NEW_DOMAIN_NAME --user $DOMAIN_ADMIN_ID admin

openstack user list --domain $DOMAIN_ID

openstack role assignment list --domain $DOMAIN_ID
