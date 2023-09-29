#!/bin/bash

set -a
source "./../../../.env"
set +a

#kubectl create namespace bnl-demo-app-ns
kubectl config set-context --current --namespace="$APP_NAMESPACE"

kubectl delete serviceaccount demo-app-sa --ignore-not-found=true
kubectl create serviceaccount demo-app-sa

# DB SECRETS
kubectl delete secret db-credentials --ignore-not-found=true
kubectl create secret generic db-credentials \
    --from-literal=url=jdbc:h2:mem:testdb \
    --from-literal=username=h2-user  \
    --from-literal=password=hardcoded-secret

# DEPLOYMENT
envsubst < deployment.yml | kubectl replace --force -f -
if ! kubectl wait deployment demo-app --for condition=Available=True --timeout=90s
  then exit 1
fi

kubectl get services demo-app
kubectl get pods