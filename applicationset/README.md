# ApplicationSet example

A self-contained [ApplicationSet](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/) using the **List generator** to fan out a single manifest into three Argo CD Applications — one per guestbook flavor in this repo.

## What it deploys

Applying [`appset.yaml`](appset.yaml) creates three Applications in the `argocd` namespace:

| Application                  | Source path           | Target namespace      |
| ---------------------------- | --------------------- | --------------------- |
| `example.guestbook-plain`    | `guestbook/`          | `guestbook-plain`     |
| `example.guestbook-helm`     | `helm-guestbook/`     | `guestbook-helm`      |
| `example.guestbook-kustomize`| `kustomize-guestbook/`| `guestbook-kustomize` |

Each Application syncs automatically with `prune` and `selfHeal` enabled, and creates its target namespace on first sync.

## Try it

```sh
kubectl apply -n argocd -f appset.yaml

# Watch the three Applications appear and sync:
kubectl get applications -n argocd | grep example.guestbook-
```

## How to extend

Add another entry under `spec.generators[0].list.elements` with a `name`, `path`, and `namespace` — the ApplicationSet controller will generate a matching Application automatically. Other generator types (Cluster, Git, Matrix, SCM Provider) are documented in the [ApplicationSet generators reference](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators/).
