#!/bin/bash

set -a
source "./../../../.env"
set +a

kubectl config set-context --current --namespace="$APP_NAMESPACE"

# DEPLOYMENT
envsubst < deployment.yml | kubectl replace --force -f -
if ! kubectl wait deployment demo-sidecar-push-to-file --for condition=Available=True --timeout=90s
  then exit 1
fi

kubectl get services demo-sidecar-push-to-file
kubectl get pods