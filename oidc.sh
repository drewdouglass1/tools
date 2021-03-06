#!/bin/bash

#*===================================================================
#*
#* Licensed Materials - Property of IBM
#* IBM Cost And Asset Management
#* Copyright IBM Corporation 2017. All Rights Reserved.
#*
#*===================================================================

set -o nounset
set -o pipefail
set -o errexit

# requires `kubectl`
# requires `jq` (sudo apt-get install jq -y)
# Usage
# ./oidc_regn.sh [-g GATEWAY_URL] [-n path/to/jsonfile] [-p auth/provider/host]
print_usage() {
  echo "usage: ./oidc_regn.sh [-g GATEWAY_URL] [-n path/to/jsonfile] [-p auth/provider/host]"
  echo "  where:"
  echo "        GATEWAY_URL: the API gateway full URL"
  echo "        path/to/jsonfile: Path to openid sample sso json"
  echo "        auth provider host url"
  echo ""
  echo "example: ./oidc_regn.sh -g https//myminikube.info:30091 -n openid_sso.json -p ip"
  echo ""
  exit 1
}

while getopts ':g:n:p:' flag; do
  case "${flag}" in
    g) host="${OPTARG}"
      if [ -z "${host+x}" ];
    then
    echo Enter the API gateway full URL:
    read -r host
    fi
    ;;
    n) filepath="${OPTARG}"
      if [ -z "${filepath+x}" ];
    then
    echo Enter the filepath
    read -r filepath
    fi
    ;;
    p) aph="${OPTARG}"
      if [ -z "${aph+x}" ];
    then
    echo Enter the aph
    read -r aph
    fi
    ;;
    *) print_usage
       exit 1 ;;
  esac
done

read_variable()
{
    var=$1
    value=$(python -c "import json;
with open('$filepath') as json_file:
    data = json.load(json_file)
    print (data['$var'])")
    echo $value
}

WLP_CLIENT_ID=$(read_variable _clientID)
WLP_CLIENT_SECRET=$(read_variable _clientSecret)
kubectl get configmaps -n ibm-common-services registration-json -o jsonpath='{.data.*}' | jq '.redirect_uris += ["'$host'/auth/sso/callback"]' > registration.json
jq '.client_id = "'$WLP_CLIENT_ID'"' registration.json > reg.json && mv reg.json registration.json
jq '.client_secret = "'$WLP_CLIENT_SECRET'"' registration.json > reg.json && mv reg.json registration.json
cat registration.json

OAUTH2_CLIENT_REGISTRATION_SECRET=$(kubectl -n ibm-common-services get secret platform-oidc-credentials -o yaml | grep OAUTH2_CLIENT_REGISTRATION_SECRET | awk '{ print $2}' | base64 --decode)

regn_resp=$(curl -kvv -w 'RESP_CODE:%{response_code}' -S -X POST -u oauthadmin:$OAUTH2_CLIENT_REGISTRATION_SECRET -H "Content-Type: application/json" -d @registration.json https://$aph:8443/oidc/endpoint/OP/registration)
if [[ "$regn_resp" == *"RESP_CODE:201"* ]]; then
    echo "Successfully registered oidc client"
else
    echo "Error registering oidc client"
    echo $regn_resp
    exit 1
fi
echo Platform UI environment variables:
echo WLP_CLIENT_ID=$WLP_CLIENT_ID
echo WLP_CLIENT_SECRET=$WLP_CLIENT_SECRET
echo PLATFORM_AUTH_SERVICE_URL=https://$aph:8443/idauth
echo cfcRouterUrl=https://$aph:8443
echo PLATFORM_IDENTITY_PROVIDER_URL=https://$aph:8443/idprovider
echo OAUTH2_CLIENT_REGISTRATION_SECRET=$OAUTH2_CLIENT_REGISTRATION_SECRET
