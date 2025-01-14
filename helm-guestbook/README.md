# Helm Guestbook Example

This example demonstrates how to deploy a Helm-based application using ArgoCD.

## Prerequisites
- A running Kubernetes cluster.
- ArgoCD installed and configured.
- `kubectl` and `argocd` CLI tools installed.

## Deploying the Helm Guestbook App

1. **Create the Application**:
   Run the following command to create the Helm Guestbook application in ArgoCD:
   ```bash
   argocd app create helm-guestbook \
     --repo https://github.com/argoproj/argocd-example-apps \
     --path helm-guestbook \
     --dest-name in-cluster \
     --dest-namespace default
