# Deploying a helm chart from a private repository with a values yaml from a private git repository

Let's assume that the helm chart is located in a private helm repository (e.g. nexus) and the `values.yaml` to configure the helm chart also comes from a private git repository.

## Configure the private helm repository

Deploy a secret to ArgoCD's namespace with this content (replace user and password):
```
apiVersion: v1
kind: Secret
metadata:
  name: nexus-helm-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  name: nexus
  type: helm
  url: https://nexus.example.com/repository/my-helm-repo/
  username: ...
  password: ...
```

For Nexus you might need to use the OAuth2 token as password.

## Configure access to the config git repository 

* Create a token for the config repo in your git repository
* Deploy a secret with this content to ArgoCD's namespace (set the created token as `password`):
```
apiVersion: v1
kind: Secret
metadata:
  name: git-repo-secret
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
type: Opaque
stringData:
  type: git
  url: https://github.com/my-user/my-config-repo.git
  username: doesnotmatter
  password: myGitConfigRepoToken
```

## Define your application

Deploy a this custom resource to ArgoCD's namespace with this content:

```
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  destination:
    server: https://kubernetes.default.svc
    namespace: mynamespace
  sources:
    - repoURL: https://github.com/my-user/my-config-repo.git
      path: .
      targetRevision: main
      ref: configrepo
    - repoURL: https://nexus.example.com/repository/my-helm-repo/
      targetRevision: 1.4.0
      helm:
        valueFiles:
          - values.yaml
          - $configrepo/values.yaml
      chart: mychart
```

### Explanation

* The first entry in `sources` defines the config repo where the `values.yaml` is located in the root folder (`path: .`). We give it the reference name `configrepo` which is used below.
* The second entry in `sources` defines the helm repository from where we want to install the chart `mychart` in version `1.4.0`. To configure the chart we use the default `values.yaml` from the helm chart (first entry) and the `values.yaml` from `configrepo` defined above.