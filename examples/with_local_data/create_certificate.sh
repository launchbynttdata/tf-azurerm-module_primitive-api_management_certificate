#!/usr/bin/env bash

which 'jq' >/dev/null 2>&1 || { echo 'jq is not installed'; exit 1; }
which 'openssl' >/dev/null 2>&1 || { echo 'openssl is not installed'; exit 1; }

cd $(mktemp -d)

openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout server.key -out server.crt \
  -subj "/CN=terratest.launch.nttdata.com" >/dev/null 2>&1

openssl pkcs12 -export -out server.pfx -inkey server.key -in server.crt -passout pass: >/dev/null 2>&1

jq -cn --arg data "$(cat server.pfx | base64 -w 0)" '{pfx: $data}'
