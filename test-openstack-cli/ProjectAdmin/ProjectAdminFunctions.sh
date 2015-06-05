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

if [ -z "$OS_PROJECT_NAME" ]; then
    echo "OS_PROJECT_NAME is not set."
    exit 2
fi

if [ -z "$OS_PROJECT_DOMAIN_NAME" ]; then
    echo "OS_PROJECT_DOMAIN_NAME is not set."
    exit 2
fi

if [ -z "$OS_PASSWORD" ]; then
    echo "OS_PASSWORD is not set."
    exit 2
fi

OS_IDENTITY_API_VERSION=3
LDAP_USER_ID=<UserName>

# Generate session token
# Authenticate project admin
# OS_TOKEN will be set to project admin token
OS_TOKEN=$(openstack token issue --os-username $OS_USERNAME -f value -c id)

# Collect domain ID
OS_PROJECT_ID=$(openstack token issue --os-username $OS_USERNAME -f value -c project_id)

ADMIN_ROLE_ID=$(openstack role show admin -f value -c id)
MEMBER_ROLE_ID=$(openstack role show Member -f value -c id)

# Project admin should be able to get details about his own project
#openstack project show $OS_PROJECT_NAME

# Project admin should be able to assign admin role to any user from the same domain
# openstack role add --user=$LDAP_USER_ID --project=$OS_PROJECT_NAME admin
echo curl -sX PUT $OS_AUTH_URL/projects/$OS_PROJECT_ID/users/$LDAP_USER_ID/roles/$ADMIN_ROLE_ID -H "X-Auth-Token: $OS_TOKEN"
curl -sX PUT $OS_AUTH_URL/projects/$OS_PROJECT_ID/users/$LDAP_USER_ID/roles/$ADMIN_ROLE_ID -H "X-Auth-Token: $OS_TOKEN"

# Project admin should be able to assign member role to any user from the same domain
#openstack role add --user=$LDAP_USER_ID --project=$OS_PROJECT_NAME Member 
echo curl -sX PUT $OS_AUTH_URL/projects/$OS_PROJECT_ID/users/$LDAP_USER_ID/roles/$MEMBER_ROLE_ID -H "X-Auth-Token: $OS_TOKEN"
curl -sX PUT $OS_AUTH_URL/projects/$OS_PROJECT_ID/users/$LDAP_USER_ID/roles/$MEMBER_ROLE_ID -H "X-Auth-Token: $OS_TOKEN"

# Project admin should be able to list roles under his own project
echo openstack role assignment list --project=$OS_PROJECT_ID
openstack role assignment list --project=$OS_PROJECT_ID

# Project admin should be able to update any user to remove role from his project
#openstack role remove --user=LDAP_USER_ID --project=$OS_PROJECT_ID admin
echo curl -sX DELETE $OS_AUTH_URL/projects/$OS_PROJECT_ID/users/$LDAP_USER_ID/roles/$MEMBER_ROLE_ID -H "X-Auth-Token: $OS_TOKEN"
curl -sX DELETE $OS_AUTH_URL/projects/$OS_PROJECT_ID/users/$LDAP_USER_ID/roles/$MEMBER_ROLE_ID -H "X-Auth-Token: $OS_TOKEN"

# Project admin should be able to list roles under his own project
echo openstack role assignment list --project=$OS_PROJECT_ID
openstack role assignment list --project=$OS_PROJECT_ID
