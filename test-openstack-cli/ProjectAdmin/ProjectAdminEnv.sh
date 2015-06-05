unset $(printenv | grep OS_ | awk 'BEGIN{FS="=";}{print $1;}')

export OS_AUTH_URL=<URL>
export OS_USERNAME=<UserName>
export OS_IDENTITY_API_VERSION=3
export OS_USER_DOMAIN_NAME=<UserDomainName>
export OS_PROJECT_NAME=<ProjectName>
export OS_PROJECT_DOMAIN_NAME=<ProjectDomainName>
export OS_REGION_NAME=<RegionName>

echo -n "OS Password for ${OS_USERNAME}: "
read -s OS_PASSWORD
echo ""
export OS_PASSWORD=$OS_PASSWORD
