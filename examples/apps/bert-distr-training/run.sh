#!/bin/bash

set -x

export KUBECONFIG=/home/petsis/.kube/config

# Port-forward the minio console to localhost
kubectl port-forward svc/myminio -n minio 9000:9000

# Set minio local alias
MC_ACCESS_KEY=$(kubectl get secret myminio -n minio -o jsonpath="{.data.rootUser}" | base64 --decode)
MC_SECRET_KEY=$(kubectl get secret myminio -n minio -o jsonpath="{.data.rootPassword}" | base64 --decode)

./mc alias set local http://localhost:9000 $MC_ACCESS_KEY $MC_SECRET_KEY

# And create the bucket

# Port-forward the minio service to localhost
# kubectl port-forward deployment/myminio -n minio 9001:9001

# Port-forward the jupyter service to localhost
kubectl --namespace=kubeflow port-forward service/proxy-public 8080:http

# Changes made:
# add more storage (if needed), using EBS on amazon. -> growpart etc etc for ext4
# change overlay size on /etc/apptainer/apptainer.conf flag from 16 to 32000
# change certificate from validatingwebhookconfiguration the same from /kubernetes/pki/ca.crt
# add more storage to ebs volume of head node for the /home -> growpart etc etc for ext4