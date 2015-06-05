#!/bin/sh
source CloudAdmin/CloudAdminEnv.sh
export NEW_DOMAIN_NAME=KiloTestDomain20152
export DOMAIN_ADMIN=<DomainAdminName>
CloudAdmin/DomainCreation/CreateDomain.sh
CloudAdmin/CloudAdminFunctions.sh
DomainAdmin/DomainAdminEnv.sh
DomainAdmin/DomainAdminFunctions.py
