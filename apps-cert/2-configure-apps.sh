#!/bin/bash

set -a
source "./../.env"
set +a

#1- Kubernetes cluster admin -  Prepare the application namespace
kubectl delete namespace "$APP_NAMESPACE" --ignore-not-found=true
kubectl create namespace "$APP_NAMESPACE"

kubectl config set-context --current --namespace="$APP_NAMESPACE"
kubectl create serviceaccount "test-app-sa"

openssl s_client -connect "$CYBERARK_CONJUR_MASTER_HOSTNAME":"$CYBERARK_CONJUR_MASTER_PORT" \
  -showcerts </dev/null 2> /dev/null | \
  awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/ {print $0}' \
  > conjur.pem
  
kubectl create configmap conjur-connect \
  --from-literal CONJUR_ACCOUNT="$CYBERARK_CONJUR_ACCOUNT" \
  --from-literal CONJUR_APPLIANCE_URL="$CYBERARK_CONJUR_APPLIANCE_URL" \
  --from-literal CONJUR_AUTHN_URL="$CYBERARK_CONJUR_APPLIANCE_URL"/authn-k8s/"$CYBERARK_CONJUR_AUTHENTICATOR_ID" \
  --from-literal AUTHENTICATOR_ID="$CYBERARK_CONJUR_AUTHENTICATOR_ID" \
  --from-file "CONJUR_SSL_CERTIFICATE=conjur.pem" 
  
envsubst < manifests/service-account-role.yml | kubectl replace --force -f -

rm conjur.pem


