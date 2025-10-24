#!/bin/bash

HOST_IP=$(hostname -I | awk '{print $1}')

# Certificate authority
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -days 365 -out ca.crt -subj "/CN=hpk-ca" \
  -addext "basicConstraints=CA:TRUE" \
  -addext "keyUsage=digitalSignature,keyEncipherment,keyCertSign" \
  -addext "subjectAltName=IP.1:127.0.0.1,IP.2:10.3.24.60,IP.3:$HOST_IP"

# Key and certificate for the services webhook
openssl genrsa -out services-webhook.key 2048
openssl req -x509 -key services-webhook.key -CA ca.crt -CAkey ca.key -days 365 -nodes -out services-webhook.crt -subj "/CN=hpk-services-webhook" \
  -addext "basicConstraints=CA:FALSE" \
  -addext "keyUsage=digitalSignature,keyEncipherment" \
  -addext "extendedKeyUsage=serverAuth,clientAuth" \
  -addext "subjectAltName=IP.1:127.0.0.1,IP.2:10.3.24.60,IP.3:$HOST_IP"
