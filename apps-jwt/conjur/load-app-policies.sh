#!/bin/bash

set -a
source "./../../.env"
set +a


envsubst < app-hosts.yml > app-hosts.yml.tmp
conjur policy update -b root -f app-hosts.yml.tmp >> app-hosts.log
rm app-hosts.yml.tmp

envsubst < host-grants.yml > host-grants.yml.tmp
conjur policy update -b root -f host-grants.yml.tmp
rm host-grants.yml.tmp

conjur variable set -i data/bnl/ocp-apps/url -v "jdbc:h2:mem:testdb"
conjur variable set -i data/bnl/ocp-apps/password -v "vault-password"
conjur variable set -i data/bnl/ocp-apps/username -v "sa"

