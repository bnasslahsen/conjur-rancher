#!/bin/bash

set -a
source "./../.env"
set +a

#Define the application as a Conjur host in policy
envsubst < policies/app-host.yml > app-host.yml.tmp
conjur policy update -b root -f app-host.yml.tmp
rm app-host.yml.tmp

# Case of Secrets in Conjur
envsubst < policies/app-secrets.yml > app-secrets.yml.tmp
conjur policy update -b root -f app-secrets.yml.tmp
rm app-secrets.yml.tmp

# Set variables
conjur variable set -i "secrets/test-app/url" -v jdbc:h2:mem:testdb
conjur variable set -i "secrets/test-app/username" -v user
conjur variable set -i "secrets/test-app/password" -v pass
