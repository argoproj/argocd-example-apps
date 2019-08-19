# Kasane

[Kasane](https://github.com/google/kasane) is a layering tool for Kubernetes which utilises Jsonnet for deep object modification and patching.

Use following steps to try the application:

* Follow instructions from [custom_tools.md](https://github.com/argoproj/argo-cd/blob/master/docs/operator-manual/custom_tools.md) to make sure `kasane` binary is available in `argocd-repo-server` pod.
* Register `kasane` plugin `argocd-cm` ConfigMap:

```yaml
apiVersion: v1
data:
  configManagementPlugins: |
    - name: kasane
      init:
        command: [kasane, update]
      generate:
        command: [kasane, show]
```
* Create application using `kasane` as a config management plugin name.

```
argocd app create kasane \
    --config-management-plugin kasane \
    --repo https://github.com/argoproj/argocd-example-apps \
    --path plugins/kasane \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace default
```
