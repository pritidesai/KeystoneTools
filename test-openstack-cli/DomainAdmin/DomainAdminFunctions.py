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

OS_IDENTITY_API_VERSION=3
DOMAIN_ADMIN=<UserName>

# Generate session token
# Authenticate domain admin
# OS_TOKEN will be set to domain admin token
export OS_TOKEN=$(openstack token issue --os-username $OS_USERNAME -f value -c id)

# Collect domain ID
export OS_DOMAIN_ID=$(openstack token issue --os-username $OS_USERNAME -f value -c domain_id)

USER_ID=`curl -sX GET -H "X-Auth-Token: ${OS_TOKEN}" "${OS_AUTH_URL}/users?domain_id=${OS_DOMAIN_ID}" | jq .users | jq "map(select(.name==\"$DOMAIN_ADMIN\")) | .[].id" | tr -d '"'`

# Domain admin should be able to list projects under his domain
echo openstack project list --domain $OS_DOMAIN_ID
openstack project list --domain $OS_DOMAIN_ID

# Domain admin should be able to create new project under his domain
PROJECT_NAME="$OS_DOMAIN_NAME-test-project-$RANDOM"
echo openstack project create --domain $OS_DOMAIN_ID $PROJECT_NAME
PROJECT_ID=$(openstack project create --domain $OS_DOMAIN_ID $PROJECT_NAME -f value -c id)

# Domain admin should be able to get info of the project
echo openstack project show --domain $OS_DOMAIN_ID $PROJECT_ID
openstack project show --domain $OS_DOMAIN_ID $PROJECT_ID

# Domain admin should be able to get a list of users under his domain
echo openstack user list --domain $OS_DOMAIN_ID
openstack user list --domain $OS_DOMAIN_ID

# Domain admin should be able grant any user admin role on his domain
echo openstack role add --domain $OS_DOMAIN_ID --user $USER_ID admin
openstack role add --domain $OS_DOMAIN_ID --user $USER_ID admin

# Domain admin should be able grant any user member role on his domain
echo openstack role add --domain $OS_DOMAIN_ID --user $USER_ID Member
openstack role add --domain $OS_DOMAIN_ID --user $USER_ID Member

# Domain admin should be able to assign any user admin role to any project under my domain.
echo openstack role add --project $PROJECT_ID --user $USER_ID admin
openstack role add --project $PROJECT_ID --user $USER_ID admin

# Domain admin should be able to assign any user member role to any project under my domain.
echo openstack role add --project $PROJECT_ID --user $USER_ID Member
openstack role add --project $PROJECT_ID --user $USER_ID Member

# Domain admin should be able grant any user from any other domain, an admin role on his domain
#echo openstack role add --domain $OS_DOMAIN_ID --user $OS_USERNAME admin
#openstack role add --domain $OS_DOMAIN_ID --user $OS_USERNAME admin

# Domain admin should be able grant any user from any other domain, a member role on his domain
#echo openstack role add --domain $OS_DOMAIN_ID --user $OS_USERNAME Member
#openstack role add --domain $OS_DOMAIN_ID --user $OS_USERNAME Member

# Domain admin should be able to assign any user from any other domain, an admin role to any project under my domain.
#echo openstack role add --project $PROJECT_ID --user $OS_USERNAME admin
#openstack role add --project $PROJECT_ID --user $OS_USERNAME admin

# Domain admin should be able to assign any user from any other domain, a member role to any project under my domain.
#echo openstack role add --project $PROJECT_ID --user $OS_USERNAME Member
#openstack role add --project $PROJECT_ID --user $OS_USERNAME Member

# Domain admin should be able to list role assignments of his domain.
echo openstack role assignment list --domain=$OS_DOMAIN_ID
openstack role assignment list --domain=$OS_DOMAIN_ID

# Domain admin should be able to list role assignments of any project under his domain.
echo openstack role assignment list --project=$PROJECT_ID
openstack role assignment list --project=$PROJECT_ID

# Domain admin should be able to revoke grant from user.
# this tests works just fine, but is not appopriate in this automation
#echo openstack role remove --domain $OS_DOMAIN_ID --user $OS_USERNAME admin
#openstack role remove --domain $OS_DOMAIN_ID --user $OS_USERNAME admin

# Domain admin should be able to revoke grant from user
echo openstack role remove --domain $OS_DOMAIN_ID --user $USER_ID Member
openstack role remove --domain $OS_DOMAIN_ID --user $USER_ID Member

# Domain admin should be able to revoke grant from user
echo openstack role remove --project $PROJECT_ID --user $USER_ID admin
openstack role remove --project $PROJECT_ID --user $USER_ID admin

# Domain admin should be able to revoke grant from user
echo openstack role remove --project $PROJECT_ID --user $USER_ID Member
openstack role remove --project $PROJECT_ID --user $USER_ID Member

# Domain admin should be able to list role assignments of any project under his domain.
echo openstack role assignment list --project=$PROJECT_ID
openstack role assignment list --project=$PROJECT_ID

# Domain admin should be able to list role assignments of his domain.
echo openstack role assignment list --domain=$OS_DOMAIN_ID
openstack role assignment list --domain=$OS_DOMAIN_ID

# Domain admin should be able to delete project from his domain
#echo openstack project delete $PROJECT_ID
#openstack project delete $PROJECT_ID

