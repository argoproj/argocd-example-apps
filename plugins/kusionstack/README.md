# KusionStack

[KusionStack](https://kusionstack.io/) is a highly flexible programmable technology stack to enable unified application delivery and operation, which aims to help enterprises build an application-centric configuration management plane and DevOps ecosystem.

Use the following steps to try the application:

* Follow instructions from the [guide](https://kusionstack.io/docs/user_docs/guides/argocd/drift-detection-by-argocd) to make sure `kusion` binary is available in `argocd-repo-server` pod.
* Register `kusion` plugin `argocd-cm` ConfigMap:

```yaml
apiVersion: v1
data:
  configManagementPlugins: |
    - name: kusion
      generate:
        command: ["sh", "-c"]
        args: ["kusion compile"]
      lockRepo: true
```

* Create a guestbook application using `kusion` as a config management plugin name.

```
argocd app create guestbook-test \
    --repo https://github.com/KusionStack/konfig.git \
    --path appops/guestbook-frontend/prod \
    --dest-namespace default \
    --dest-server https://kubernetes.default.svc \
    --config-management-plugin kusion
```
