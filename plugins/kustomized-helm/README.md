# Helm + Kustomize

Sometimes Helm chart don't have all required parameters and additional customization is required. This example application demonstrates how to combine Helm and Kustomize and use it
as a config management plugin in Argo CD.

Use following steps to try the application:

* configure `kustomized-helm` tool in `argocd-cm` ConfigMap:

```yaml
  configManagementPlugins: |
    - name: kustomized-helm
      init:
        command: ["/bin/sh", "-c"]
        args: ["helm dependency build"]
      generate:
        command: [sh, -c]
        args: ["helm template --release-name release-name . > all.yaml && kustomize build"]
```

* create application using `kustomized-helm` as a config management plugin name:


```
argocd app create kustomized-helm \
    --config-management-plugin kustomized-helm \
    --repo https://github.com/argoproj/argocd-example-apps \
    --path plugins/kustomized-helm \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace default
```
