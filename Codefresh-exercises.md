here are my codfresh exercise notes


## App of Apps
```
. <(argocd completion bash)

 argocd app create my-favorite-apps \
   --project default \
   --sync-policy none \
   --repo https://github.com/lalyos/gitops-cert-level-2-examples.git \
   --path ./app-of-apps/my-app-list \
   --dest-namespace argocd \
   --dest-server https://kubernetes.default.svc
```

## MultiCluster Deployment

```
 argocd app create external-app \
   --project default \
   --sync-policy auto \
   --repo https://github.com/lalyos/gitops-cert-level-2-examples.git \
   --path ./simple-application \
   --dest-namespace default \
   --dest-server https://10.5.0.176:6443
```

```
 argocd app create internal-app \
   --project default \
   --sync-policy auto \
   --repo https://github.com/lalyos/gitops-cert-level-2-examples.git \
   --path ./simple-application \
   --dest-namespace default \
   --dest-server https://kubernetes.default.svc
```
