#!/bin/bash
############
# Colors  ##
############
Green='\x1B[0;32m'
Red='\x1B[0;31m'
Yellow='\x1B[0;33m'
Cyan='\x1B[0;36m'
no_color='\x1B[0m' # No Color
beer='\xF0\x9f\x8d\xba'
delivery='\xF0\x9F\x9A\x9A'
beers='\xF0\x9F\x8D\xBB'
coffee='\xE2\x98\x95';
eyes='\xF0\x9F\x91\x80'
cloud='\xE2\x98\x81'
crossbones='\xE2\x98\xA0'
litter='\xF0\x9F\x9A\xAE'
fail='\xE2\x9B\x94'
harpoons='\xE2\x87\x8C'
tools='\xE2\x9A\x92'
present='\xF0\x9F\x8E\x81'
applelogo='\xEF\xA3\xBF'
#############


USAGE="${crossbones}   ${eyes}  Usage: ./${0##*/} ROKS_HOSTNAME\n
\tROKS_HOSTNAME:\tPublic Cloud Hostname for CPK4MCM (e.g. icp-console.something.region.containers.appdomain.cloud \n"

if [[ -z "${CPK4MCM_FQDN}" ]]; then
  echo -e "${tools}  ${eyes}   No hostname provided in 00-variables file."
  if [ $# -lt 1 ]; then
    echo -e $USAGE
    exit 1
  fi
  CPK4MCM_FQDN="${1}"
fi

if grep -Fq "xxxxxx" ./ansible/inventory;
then
    echo -e "${crossbones}  ${eyes}  I'd recommend updating the Ansible Tower admin password found within ${Cyan}ansible/inventory${no_color} from the current ${Yellow}xxxxxx${no_color}"
    exit 1
fi

BASE_FQDN=$(echo "${CPK4MCM_FQDN}" | cut -d"." -f2-)
CURRDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

detectCustomPolicy=$(kubectl get clusterimagepolicies --no-headers | awk '{print $1}' | grep "ibmcloud-custom-cluster-image-policy" | grep "^.*$" -c || true)

if [ "$detectCustomPolicy" -eq "0" ]; then
	echo -e "${harpoons}  Creating ${Cyan}ibmcloud-custom-cluster-image-policy${no_color} clusterimagepolicy ..."
cat <<EOF | kubectl create -f -
  apiVersion: v1
  items:
  - apiVersion: securityenforcement.admission.cloud.ibm.com/v1beta1
    kind: ClusterImagePolicy
    metadata:
      name: ibmcloud-custom-cluster-image-policy
    spec:
      repositories:
      - name: registry.redhat.io/*
  kind: List
  metadata:
    resourceVersion: ""
    selfLink: ""
EOF
else
	REPOS="registry.redhat.io/*"
	for REPO in $REPOS; do kubectl patch clusterimagepolicies ibmcloud-custom-cluster-image-policy -p '[{"op":"add","path":"/spec/repositories/-","value":{"name":"'${REPO}'"}}]' --type=json; done
fi