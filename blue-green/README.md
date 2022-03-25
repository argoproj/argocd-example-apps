# Blue Green

The [blue green strategy](https://argoproj.github.io/argo-rollouts/concepts/#blue-green) is not supported by Kubernetes Deployments, 
but it is available via [Argo Rollouts](https://github.com/argoproj/argo-rollouts). This example demonstrates how to implement a blue-green 
deployment using Argo CD and Argo Rollouts together.

## Prerequisites:

1. Install Argo CD: https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/#core 
2. Install Argo Rollouts: https://argoproj.github.io/argo-rollouts/installation/
3. Install the kubectl rollouts plugin: https://argoproj.github.io/argo-rollouts/installation/#kubectl-plugin-installation


## Walkthrough

1. Let's start by creating an Argo CD Application and sync it with the helm chart in this git repository:

```
argocd app create blue-green --repo https://github.com/argoproj/argocd-example-apps --dest-server https://kubernetes.default.svc --dest-namespace default --path blue-green && argocd app sync blue-green
```

Once the application is synced, you can access it using `blue-green-helm-guestbook` service:

```
kubectl port-forward svc/blue-green-helm-guestbook 8080:80 -n default
```

After running the command above, the application can be viewed at localhost:8080.

2. Change the image version parameter to trigger the blue-green deployment process:

```
argocd app set blue-green -p image.tag=0.2 && argocd app sync blue-green
```

After running the command above, the Application runs `ks-guestbook-demo:0.1` and `ks-guestbook-demo:0.2` images simultaneously.
The `ks-guestbook-demo:0.2` is still considered blue or only available via the preview service `blue-green-helm-guestbook-preview`. 

You can run the following to view the blue preview service:

```
kubectl port-forward svc/blue-green-helm-guestbook-preview 8081:80 -n default
```

The blue preview version of the application will be available at localhost:8081, but the active version of the application at localhost:8080 
is still displaying the older version of the application.

3. Promote `ks-guestbook-demo:0.2` to `green` by patching `Rollout` resource:

```
kubectl argo rollouts promote blue-green-helm-guestbook -n default
```

This promotes `ks-guestbook-demo:0.2` to `green` status and the `Rollout` deletes the old replica which runs `ks-guestbook-demo:0.1`.

If you stop and rerun `kubectl port-forward svc/blue-green-helm-guestbook 8080:80 -n default` again, you should see the new 
version is now available via the active service at localhost:8080.
