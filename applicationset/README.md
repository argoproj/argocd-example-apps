# ApplicationSet examples

One example per [ApplicationSet generator](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators/), kept minimal so each file teaches the *configuration shape* of its generator. Every generated Application deploys only a single ConfigMap — no Deployments, no Services — so the demo footprint stays tiny.

## Files

| File                  | Generator       | Generates                              |
| --------------------- | --------------- | -------------------------------------- |
| [`list.yaml`](list.yaml)                 | List            | `appset-list-dev`, `appset-list-prod`  |
| [`cluster.yaml`](cluster.yaml)           | Cluster         | `appset-cluster-in-cluster`            |
| [`git.yaml`](git.yaml)                   | Git (2 docs)    | see below                              |
| [`matrix.yaml`](matrix.yaml)             | Matrix          | `appset-matrix-dev-us`, `appset-matrix-prod-us` |
| [`merge.yaml`](merge.yaml)               | Merge           | `appset-merge-dev`, `appset-merge-prod` |
| [`pull-request.yaml`](pull-request.yaml) | Pull Request    | none (label filter matches nothing)    |

`git.yaml` contains two ApplicationSets:

- `git-directories` — scans `appset-examples/app-*` and generates `appset-git-dir-app-a` and `appset-git-dir-app-b`.
- `git-broken` — **intentionally broken**: points at a git revision that doesn't exist. The generator fails at fetch, the ApplicationSet CR shows an `ErrorOccurred` condition, and no child Applications are generated. Demonstrates what generator-level failure looks like.

## Two failure modes on display

- **Quiet zero-result** — `pull-request.yaml` runs successfully but its label filter matches no PRs, so it generates zero Applications. The ApplicationSet stays healthy.
- **Loud generator failure** — `git-broken` in `git.yaml` can't fetch its source, so the ApplicationSet itself goes red with an error condition.

## Source content scanned by Git generators

Lives at the repo root in [`../appset-examples/`](../appset-examples/) (outside this folder so ArgoCD's directory-source `recurse: false` default doesn't pick it up via the parent Application). Contents:

- `app-a/configmap.yaml`, `app-b/configmap.yaml` — single ConfigMaps that the Git Directories generator finds
