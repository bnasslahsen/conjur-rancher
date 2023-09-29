#!/bin/bash

set -a
source "./../../../.env"
set +a

kubectl config set-context --current --namespace="$APP_NAMESPACE"

# DB SECRETS
envsubst < k8s-secrets.yml | kubectl replace --force -f -

# DEPLOYMENT
envsubst < deployment.yml | kubectl replace --force -f -
if ! kubectl wait deployment "test-app" --for condition=Available=True --timeout=90s
  then exit 1
fi

kubectl get services "test-app"
kubectl get pods
