# ApplicationSet example

A self-contained [ApplicationSet](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/) using the **List generator** to deploy the same `guestbook/` manifest across three environments — the most common real-world ApplicationSet pattern.

## What it deploys

Applying [`appset.yaml`](appset.yaml) creates three Applications, all sourcing from `guestbook/`, each targeting its own environment namespace:

| Application               | Target namespace          |
| ------------------------- | ------------------------- |
| `appset-guestbook-dev`    | `appset-guestbook-dev`    |
| `appset-guestbook-staging`| `appset-guestbook-staging`|
| `appset-guestbook-prod`   | `appset-guestbook-prod`   |

Each Application syncs automatically with `prune` and `selfHeal` enabled, and creates its target namespace on first sync.

## How to extend

Add another entry under `spec.generators[0].list.elements` (e.g. `- env: qa`) — the ApplicationSet controller will generate a matching Application automatically. Other generator types (Cluster, Git, Matrix, SCM Provider) are documented in the [ApplicationSet generators reference](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators/).
