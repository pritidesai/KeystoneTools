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
CPE_DOMAIN_NAME=openstack-dev-test
DEV_DOMAIN_NAME=DEV
KILO_TEST_DOMAIN_NAME=KiloTestDomain20152
SERVICE_DOMAIN_NAME=ServiceDomain
SERVICE_USER_NAME="$KILO_TEST_DOMAIN_NAME-service-user-$RANDOM"
LDAP_USER_ID=<UserName>

# Generate session token
# Authenticate domain admin
OS_TOKEN=$(openstack token issue --os-username $OS_USERNAME -f value -c id)

# Collect domain ID
OS_DOMAIN_ID=$(openstack token issue --os-username $OS_USERNAME -f value -c domain_id)

# Collect openstack-dev-test Domain ID
CPE_DOMAIN_ID=$(openstack domain show $CPE_DOMAIN_NAME -f value -c id)
echo "CPE Domain ID $CPE_DOMAIN_ID"

# Collect DEV Domain ID
DEV_DOMAIN_ID=$(openstack domain show $DEV_DOMAIN_NAME -f value -c id)
echo "DEV Domain ID $DEV_DOMAIN_ID"

# Collect Kilo Test Domain ID
KILO_TEST_DOMAIN_ID=$(openstack domain show $KILO_TEST_DOMAIN_NAME -f value -c id)
echo "Kilo Test Domain ID $KILO_TEST_DOMAIN_ID"

# Collect CPE Domain ID
SERVICE_DOMAIN_ID=$(openstack domain show $SERVICE_DOMAIN_NAME -f value -c id)
echo "Service Domain ID $SERVICE_DOMAIN_ID"

TEST_USER_ID=`curl -sX GET -H "X-Auth-Token: ${OS_TOKEN}" "${OS_AUTH_URL}/users?domain_id=${KILO_TEST_DOMAIN_ID}" | jq .users | jq "map(select(.name==\"$OS_USERNAME\")) | .[].id" | tr -d '"'`

# Cloud admin should be able to list domains in cloudfire
echo openstack domain list
openstack domain list

#######################################################################
# User List
#######################################################################

# Cloud admin should be able to list users in any domain
# Testing default domain here
echo openstack user list --domain $OS_DOMAIN_NAME
openstack user list --domain $OS_DOMAIN_NAME

## Cloud admin should be able to list users in any domain
## Testing ServiceDomain domain here
echo openstack user list --domain $SERVICE_DOMAIN_NAME
openstack user list --domain $SERVICE_DOMAIN_NAME

# Cloud admin should be able to list users in any domain
# Testing DEV domain here
echo openstack user list --domain $DEV_DOMAIN_NAME
openstack user list --domain $DEV_DOMAIN_NAME

# Cloud admin should be able to list users in any domain
# Testing Kilo Test domain here
echo openstack user list --domain $KILO_TEST_DOMAIN_NAME
openstack user list --domain $KILO_TEST_DOMAIN_NAME

#######################################################################
# Project List
#######################################################################

# Cloud admin should be able to list projects in cloudfire
echo openstack project list
openstack project list

# Cloud admin should be able to list projects in any domain
echo openstack project list --domain $CPE_DOMAIN_ID
openstack project list --domain $CPE_DOMAIN_ID

# Cloud admin should be able to list projects in any domain 
echo openstack project list --domain $OS_DOMAIN_ID
openstack project list --domain $OS_DOMAIN_ID

# Cloud admin should be able to list projects in any domain 
echo openstack project list --domain $DEV_DOMAIN_ID
openstack project list --domain $DEV_DOMAIN_ID

# Cloud admin should be able to list projects in any domain 
echo openstack project list --domain $KILO_TEST_DOMAIN_ID
openstack project list --domain $KILO_TEST_DOMAIN_ID

#######################################################################
# Creating/Deleting Service Users 
#######################################################################

## Cloud admin should be able to create ServiceUsers in ServiceDomain
echo openstack user create $SERVICE_USER_NAME --password=changeme --domain=$SERVICE_DOMAIN_NAME
openstack user create $SERVICE_USER_NAME --password=changeme --domain=$SERVICE_DOMAIN_NAME
#
## Cloud admin should be able to delete ServiceUser from ServiceDomain
SERVICE_USER_ID=$(openstack user show $SERVICE_USER_NAME --domain $SERVICE_DOMAIN_NAME -f value -c id)
echo openstack user delete $SERVICE_USER_ID
openstack user delete $SERVICE_USER_ID

#######################################################################
# Creating Project
#######################################################################

# Cloud admin should be able to create new project under any domain
PROJECT_NAME="$CPE_DOMAIN_NAME-test-project-$RANDOM"
echo openstack project create --domain $CPE_DOMAIN_ID $PROJECT_NAME
PROJECT_ID=$(openstack project create --domain $CPE_DOMAIN_ID $PROJECT_NAME -f value -c id)

# Cloud admin should be able to get details of any project
echo openstack project show --domain $CPE_DOMAIN_ID $PROJECT_ID
openstack project show --domain $CPE_DOMAIN_ID $PROJECT_ID

#######################################################################
# Grant/Revoke Role / authenticate
#######################################################################

# Cloud admin should be able grant any user admin role on any domain
echo openstack user create $SERVICE_USER_NAME --password=changeme --domain=$SERVICE_DOMAIN_NAME
openstack user create $SERVICE_USER_NAME --password=changeme --domain=$SERVICE_DOMAIN_NAME
SERVICE_USER_ID=$(openstack user show $SERVICE_USER_NAME --domain $SERVICE_DOMAIN_NAME -f value -c id)
echo openstack role add --domain $CPE_DOMAIN_ID --user $SERVICE_USER_ID admin
openstack role add --domain $CPE_DOMAIN_ID --user $SERVICE_USER_ID admin

echo openstack role add --domain $CPE_DOMAIN_ID --user $TEST_USER_ID admin
openstack role add --domain $CPE_DOMAIN_ID --user $TEST_USER_ID admin

## Service User should be to generate token against this domain
openstack token issue --os-username=$SERVICE_USER_NAME --os-password=changeme --os-domain-name=$CPE_DOMAIN_NAME --os-user-domain-name=$SERVICE_DOMAIN_NAME

# Cloud admin should be able to revoke grant from any user
# Cloud admin should be able grant any user member role on any domain
echo openstack role add --domain $CPE_DOMAIN_ID --user $SERVICE_USER_ID Member
openstack role add --domain $CPE_DOMAIN_ID --user $SERVICE_USER_ID Member

# Cloud admin should be able grant any user member role on any domain
echo openstack role add --domain $CPE_DOMAIN_ID --user $TEST_USER_ID Member
openstack role add --domain $CPE_DOMAIN_ID --user $TEST_USER_ID Member

## Service User should be to generate token against this domain
openstack token issue --os-username=$SERVICE_USER_NAME --os-password=changeme --os-domain-name=$CPE_DOMAIN_NAME --os-user-domain-name=$SERVICE_DOMAIN_NAME

# Domain admin should be able to assign any user admin role to any project under any domain.
echo openstack role add --project $PROJECT_ID --user $SERVICE_USER_ID admin
openstack role add --project $PROJECT_ID --user $SERVICE_USER_ID admin

# Cloud admin should be able to assign any user admin role to any project under any domain.
echo openstack role add --project $PROJECT_ID --user $SERVICE_USER_ID admin
openstack role add --project $PROJECT_ID --user $SERVICE_USER_ID admin

# Cloud admin should be able to assign any user member role to any project under any domain.
echo openstack role add --project $PROJECT_ID --user $SERVICE_USER_ID Member
openstack role add --project $PROJECT_ID --user $SERVICE_USER_ID Member

# Cloud admin should be able to assign any user admin role to any project under any domain.
echo openstack role add --project $PROJECT_ID --user $TEST_USER_ID admin
openstack role add --project $PROJECT_ID --user $TEST_USER_ID admin

# Cloud admin should be able to assign any user member role to any project under any domain.
echo openstack role add --project $PROJECT_ID --user $TEST_USER_ID Member
openstack role add --project $PROJECT_ID --user $TEST_USER_ID Member

## Service User should be to generate token against this project
unset OS_DOMAIN_NAME
openstack token issue --os-username=$SERVICE_USER_NAME --os-password=changeme --os-user-domain-name=$SERVICE_DOMAIN_NAME --os-project-name=$PROJECT_NAME --os-project-domain-name=$CPE_DOMAIN_NAME
export OS_DOMAIN_NAME=Default

#######################################################################
# Role Assignment List
#######################################################################

# Cloud admin should be able to list role assignments of any domain.
echo openstack role assignment list --domain=$CPE_DOMAIN_ID
openstack role assignment list --domain=$CPE_DOMAIN_ID

# Cloud admin should be able to list role assignments of any project under any domain.
echo openstack role assignment list --project=$PROJECT_ID
openstack role assignment list --project=$PROJECT_ID

# Cloud admin should be able to revoke grant from any user
echo openstack role remove --project $PROJECT_ID --user $SERVICE_USER_ID admin 
openstack role remove --project $PROJECT_ID --user $SERVICE_USER_ID admin

echo openstack role remove --project $PROJECT_ID --user $TEST_USER_ID admin 
openstack role remove --project $PROJECT_ID --user $TEST_USER_ID admin

#echo openstack role remove --domain $CPE_DOMAIN_ID --user $LDAP_USER_ID admin 
#openstack role remove --domain $CPE_DOMAIN_ID --user $LDAP_USER_ID admin

# Cloud admin should be able to revoke grant from any user
echo openstack role remove --domain $CPE_DOMAIN_ID --user $TEST_USER_ID admin 
openstack role remove --domain $CPE_DOMAIN_ID --user $LDAP_USER_ID admin

#######################################################################
# Role Assignment List
#######################################################################

# Cloud admin should be able to list role assignments of any domain.
echo openstack role assignment list --domain=$CPE_DOMAIN_ID
openstack role assignment list --domain=$CPE_DOMAIN_ID

# Cloud admin should be able to list role assignments of any project under any domain.
echo openstack role assignment list --project=$PROJECT_ID
openstack role assignment list --project=$PROJECT_ID

#######################################################################
# Project Delete 
#######################################################################

# Cloud admin should be able to delete project under any domain
#echo openstack project delete $PROJECT_ID
#openstack project delete $PROJECT_ID

#######################################################################
# Domain Delete 
#######################################################################

## Cloud admin should be able to delete any domain
#echo openstack project delete $CPE_DOMAIN_ID
#openstack project delete $CPE_DOMAIN_ID

