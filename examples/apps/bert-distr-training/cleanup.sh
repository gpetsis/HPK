#!/bin/bash
export KUBECONFIG=~/.kube/config

# Remove Helm releases
helm uninstall my-jupyter -n kubeflow || echo "my-jupyter release not found"
helm uninstall my-minio -n minio || echo "my-minio release not found"

# Remove Kubeflow training operator
kubectl delete -k "github.com/kubeflow/training-operator/manifests/overlays/standalone?ref=v1.7.0" || echo "Training operator not found"

# Delete namespaces (this will also delete all resources within them)
kubectl delete ns kubeflow || echo "kubeflow namespace not found"
kubectl delete ns minio || echo "minio namespace not found"
kubectl delete ns openebs || echo "openebs namespace not found"

# Remove OpenEBS (assuming it was installed in openebs namespace)
# If OpenEBS was installed differently, you may need to adjust this
kubectl delete all --all -n openebs || echo "No resources in openebs namespace"

# Remove Helm repositories
helm repo remove minio || echo "minio repo not found"
helm repo remove jupyterhub || echo "jupyterhub repo not found"

# Update helm repos to reflect changes
helm repo update

# Clean up local files (optional)
rm -f ./mc || echo "mc client not found"

echo "Cleanup completed!"