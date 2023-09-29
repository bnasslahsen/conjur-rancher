#!/bin/bash

set -a
source "../.env"
set +a

kubectl config set-context --current --namespace="$CYBERARK_CONJUR_NAMESPACE"

#kubectl get secrets -n bnl-demo-conjur-ns | grep 'authn-k8s-sa.*service-account-token' | head -n1
SA_TOKEN="$(kubectl get secret authn-k8s-sa-service-account-token -n bnl-demo-conjur-ns  --output='go-template={{ .data.token }}' | base64 -d)"
echo "SA_TOKEN=\"$SA_TOKEN\"" > "$CYBERARK_CONJUR_K8S_INFO"

K8S_API_URL="$(kubectl config view --raw --minify --flatten --output='jsonpath={.clusters[].cluster.server}')"
echo "K8S_API_URL=\"$K8S_API_URL\"" >> "$CYBERARK_CONJUR_K8S_INFO"

K8S_CA_CERT="$(kubectl get secret "$TOKEN_SECRET_NAME" -o json --output='jsonpath={.data.ca\.crt}'  | base64 --decode)"
echo "K8S_CA_CERT=\"$K8S_CA_CERT\"" >> "$CYBERARK_CONJUR_K8S_INFO"