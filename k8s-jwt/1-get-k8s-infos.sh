#!/bin/bash

set -a
source "../.env"
set +a

JWKS_URI=$(kubectl get --raw /.well-known/openid-configuration | jq -r '.jwks_uri')
echo "JWKS_URI=\"$JWKS_URI\"" > "$CYBERARK_CONJUR_K8S_INFO"

kubectl get --raw $(kubectl get --raw /.well-known/openid-configuration | jq -r '.jwks_uri') > jwks.json

SA_ISSUER="$(kubectl get --raw /.well-known/openid-configuration | jq -r '.issuer')"
echo "SA_ISSUER=\"$SA_ISSUER\"" >> "$CYBERARK_CONJUR_K8S_INFO"
