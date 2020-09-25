oc create secret docker-registry ibm-entitlement-key \
    --docker-username=cp \
    --docker-password=eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1ODc2NTcyNzgsImp0aSI6ImI5NWE5MDM4YjI2ZDQxNGFhNDAxYmI4YjcxODVmNWY2In0.bJCO1GhAhSsYxYdOCXw_bZiZ6ANxJsELTpYLKofNezg \
    --docker-server=cp.icr.io \
    --namespace=$1
