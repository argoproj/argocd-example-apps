# Using kube-green with Argo CD

- https://kube-green.dev/
- https://kube-green.dev/docs/tutorials/kind/

```
kind create cluster --name kube-green
# install akuity agent
```

- During sleep window, the Application is OutOfSync. The diff is on the replicas of the deployment.
  - https://argo-cd.readthedocs.io/en/stable/user-guide/best_practices/#leaving-room-for-imperativeness
  - or ignoreDiff.