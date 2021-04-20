#!/bin/bash
# run this script with sousorce or .
# ARM_CLIENT_SECRET (service principal password) cannot be retrieved after creation but can be reset, see https://stackoverflow.com/a/62971780/4458566

function parse_json()
{
    echo $1 | \
    sed -e 's/[{}]/''/g' | \
    sed -e 's/", "/'\",\"'/g' | \
    sed -e 's/" ,"/'\",\"'/g' | \
    sed -e 's/" , "/'\",\"'/g' | \
    sed -e 's/","/'\"---SEPERATOR---\"'/g' | \
    awk -F=':' -v RS='---SEPERATOR---' "\$1~/\"$2\"/ {print}" | \
    sed -e "s/\"$2\"://" | \
    tr -d "\n\t" | \
    sed -e 's/\\"/"/g' | \
    sed -e 's/\\\\/\\/g' | \
    sed -e 's/^[ \t]*//g' | \
    sed -e 's/^"//'  -e 's/"$//'
}

az login

response_az_list=$(az account list)

SUBSCRIPTION_ID=$(parse_json "$response_az_list" id)

response_sp_create=$(az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID")

echo "Setting environment variables for Terraform"

CLIENT_ID=$(parse_json "$response_sp_create" appId)
CLIENT_SECRET=$(parse_json "$response_sp_create" password)
TENANT_ID=$(parse_json "$response_az_list" tenantId)

export ARM_CLIENT_ID="$CLIENT_ID"
export ARM_CLIENT_SECRET="$CLIENT_SECRET"
export ARM_TENANT_ID="$TENANT_ID"
export ARM_SUBSCRIPTION_ID="$SUBSCRIPTION_ID"

echo "ARM_CLIENT_ID : $CLIENT_ID"
echo "ARM_CLIENT_SECRET : $CLIENT_SECRET"
echo "ARM_TENANT_ID : $TENANT_ID"
echo "ARM_SUBSCRIPTION_ID : $SUBSCRIPTION_ID"

echo "Done"