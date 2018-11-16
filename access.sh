#!/bin/sh
export ORG="<your_org>"
echo $ORG
cf login -a https://api.ng.bluemix.net -u $1 -p $2 -o "$ORG" -s "<your_space>"

echo Add a user into org and set auditor role
bx account org-user-add $3 "$ORG"
bx account org-role-set $3 "$ORG" OrgAuditor
bx account space-role-set $3 "$ORG" "<your_space>" SpaceDeveloper

export ORG="<your_org2>"
echo $ORG
echo Add a user into org and set auditor role
bx account org-user-add $3 "$ORG"
bx account org-role-set $3 "$ORG" OrgAuditor
bx account space-role-set $3 "$ORG" "QA" SpaceDeveloper
bx account space-role-set $3 "$ORG" "Production" SpaceDeveloper

export ORG="<your_org3>"
echo $ORG
echo Add a user into org and set auditor role
bx account org-user-add $3 "$ORG"
bx account org-role-set $3 "$ORG" OrgAuditor
bx account space-role-set $3 "$ORG" "API" SpaceDeveloper
bx account space-role-set $3 "$ORG" "QA" SpaceDeveloper
bx account space-role-set $3 "$ORG" "Production" SpaceDeveloper