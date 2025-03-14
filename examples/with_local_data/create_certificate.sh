#!/usr/bin/env bash

which 'jq' >/dev/null 2>&1 || { echo 'jq is not installed'; exit 1; }
which 'openssl' >/dev/null 2>&1 || { echo 'openssl is not installed'; exit 1; }

if [ ! -f "test.pfx" ]; then
  openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout test.key -out test.crt \
    -subj "/CN=terratest.launch.nttdata.com" >/dev/null 2>&1

  openssl pkcs12 -export -out test.pfx -inkey test.key -in test.crt -passout pass: >/dev/null 2>&1
fi

jq -cn --arg data "$(cat test.pfx | base64 -w 0)" '{pfx: $data}'
