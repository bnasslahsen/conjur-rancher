#!/bin/bash

set -a
source "../.env"
set +a

kubectl delete namespace "$CYBERARK_CONJUR_NAMESPACE" --ignore-not-found=true
kubectl delete clusterrole "conjur-clusterrole" --ignore-not-found=true
kubectl create namespace "$CYBERARK_CONJUR_NAMESPACE"
kubectl config set-context --current --namespace="$CYBERARK_CONJUR_NAMESPACE"

openssl s_client -connect "$CYBERARK_CONJUR_MASTER_HOSTNAME":"$CYBERARK_CONJUR_MASTER_PORT" \
  -showcerts </dev/null 2> /dev/null | \
  awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/ {print $0}' \
  > conjur.pem
  
kubectl create configmap conjur-configmap \
  --from-literal authnK8sAuthenticatorID="$CYBERARK_CONJUR_AUTHENTICATOR_ID" \
  --from-literal authnK8sClusterRole="conjur-clusterrole" \
  --from-literal authnK8sNamespace="$CYBERARK_CONJUR_NAMESPACE" \
  --from-literal authnK8sServiceAccount="authn-k8s-sa" \
  --from-literal conjurAccount="$CYBERARK_CONJUR_ACCOUNT" \
  --from-literal conjurApplianceUrl="$CYBERARK_CONJUR_APPLIANCE_URL" \
  --from-literal conjurSslCertificateBase64="$(cat conjur.pem| base64)" \
  --from-file conjurSslCertificate="conjur.pem"
  
rm conjur.pem

envsubst < service-account-role.yml | kubectl replace --force -f -

