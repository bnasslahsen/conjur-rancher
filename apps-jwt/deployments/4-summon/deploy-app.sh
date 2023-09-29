#!/bin/bash

set -a
source "./../../../.env"
set +a

kubectl config set-context --current --namespace="$APP_NAMESPACE"

kubectl delete configmap conjur-connect-summon --ignore-not-found=true
kubectl create configmap conjur-connect-summon \
  --from-literal CONJUR_ACCOUNT="$CONJUR_ACCOUNT" \
  --from-literal CONJUR_APPLIANCE_URL="$CYBERARK_CONJUR_FOLLOWER_URL" \
  --from-literal CONJUR_AUTHN_URL="$CYBERARK_CONJUR_FOLLOWER_URL"/authn-jwt/"$CYBERARK_CONJUR_AUTHENTICATOR_ID" \
  --from-literal CONJUR_AUTHN_JWT_SERVICE_ID="$CYBERARK_CONJUR_AUTHENTICATOR_ID" \
  --from-literal CONJUR_AUTHENTICATOR_ID="$CYBERARK_CONJUR_AUTHENTICATOR_ID"  \
  --from-literal CONJUR_JWT_TOKEN_PATH="/var/run/secrets/kubernetes.io/serviceaccount/token" \
  --from-file "CONJUR_SSL_CERTIFICATE=$CONJUR_CERT_FILE"

kubectl delete serviceaccount demo-app-summon-init-sa --ignore-not-found=true
kubectl create serviceaccount demo-app-summon-init-sa

# SUMMON CONFIGMAP
kubectl delete configmap summon-config-init --ignore-not-found=true
envsubst < secrets.template.yml > secrets.yml
kubectl create configmap summon-config-init --from-file=secrets.yml
rm secrets.yml

# DEPLOYMENT
envsubst < deployment.yml | kubectl replace --force -f -
if ! kubectl wait deployment demo-app-summon-init --for condition=Available=True --timeout=90s
  then exit 1
fi

kubectl get services demo-app-summon-init
kubectl get pods
