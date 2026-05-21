# Degraded Example

This folder contains Kubernetes manifests for a degraded application. The purpose of this app is to demonstrate how ArgoCD displays and manages degraded resources.

## Purpose
The `degraded-example` app is designed to help users understand how ArgoCD handles and displays issues such as:
- Image pull errors
- Misconfigured services
- Missing dependencies (e.g., ConfigMaps, Secrets)
- Storage and scheduling issues

These examples simulate real-world problems that can occur in Kubernetes deployments.

---