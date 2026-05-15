# ApplicationSet examples

One example per [ApplicationSet generator](https://argo-cd.readthedocs.io/en/stable/operator-manual/applicationset/Generators/), kept minimal so each file teaches the _configuration shape_ of its generator. Every generated Application deploys only a single ConfigMap — no Deployments, no Services — so the demo footprint stays tiny.

## Files

| File                                             | Generator            | Generates                                       |
| ------------------------------------------------ | -------------------- | ----------------------------------------------- |
| [`list.yaml`](list.yaml)                         | List                 | `appset-list-dev`, `appset-list-prod`           |
| [`cluster.yaml`](cluster.yaml)                   | Cluster              | `appset-cluster-in-cluster`                     |
| [`git.yaml`](git.yaml)                           | Git (2 docs)         | see below                                       |
| [`matrix.yaml`](matrix.yaml)                     | Matrix               | `appset-matrix-dev-us`, `appset-matrix-prod-us` |
| [`merge.yaml`](merge.yaml)                       | Merge                | `appset-merge-dev`, `appset-merge-prod`         |
| [`pull-request.yaml`](pull-request.yaml)         | Pull Request         | none (label filter matches nothing)             |
| [`progressive-sync.yaml`](progressive-sync.yaml) | Matrix + RollingSync | see below                                       |
| [`appset-any-ns-team-*.yaml`](appset-any-ns-team-frontend.yaml) | List (3 files) | see below |

`git.yaml` contains two ApplicationSets:

- `git-directories` — scans `lightweight/app-*` and generates `appset-git-dir-app-a` and `appset-git-dir-app-b`.
- `git-broken` — **intentionally broken**: points at a git revision that doesn't exist. The generator fails at fetch, the ApplicationSet CR shows an `ErrorOccurred` condition, and no child Applications are generated. Demonstrates what generator-level failure looks like.

`progressive-sync.yaml` generates 6 Applications (2 per environment) with staged rollout:

- `appset-progressive-dev-us-east`, `appset-progressive-dev-us-west` — sync first, all at once
- `appset-progressive-qa-us-east`, `appset-progressive-qa-us-west` — manual gate (requires manual sync)
- `appset-progressive-prod-us-east`, `appset-progressive-prod-us-west` — gradual rollout (1 at a time)

## ApplicationSet in any namespace

Three ApplicationSets demonstrate the "ApplicationSet in any namespace" feature (beta since v2.8):

- `appset-any-ns-team-frontend.yaml` — ApplicationSet named `services` in `team-frontend` namespace generates `api` and `worker` Applications
- `appset-any-ns-team-backend.yaml` — ApplicationSet named `services` in `team-backend` namespace generates `api` and `worker` Applications
- `appset-any-ns-team-platform.yaml` — ApplicationSet named `services` in `team-platform` namespace generates `api` and `worker` Applications

**Key characteristics:**
- ApplicationSets are created in team namespaces (not `argocd`)
- All three use the same ApplicationSet name (`services`) but in different namespaces
- Generated Applications are automatically created in the same namespace as the ApplicationSet
- Each generates two Applications: `api` and `worker`
- All use `lightweight/app-b` as the source path
- Requires `applicationsetcontroller.namespaces` configuration
- Requires corresponding AppProjects with `sourceNamespaces` configured
- CLI reference format: `namespace/name` (e.g., `argocd appset get services/team-frontend`)

## Progressive Sync behavior

`progressive-sync.yaml` demonstrates the RollingSync strategy with reverse deletion order:

- **Stage 1 (dev)**: Both dev apps sync simultaneously when changes are pushed
- **Stage 2 (qa)**: QA apps require manual sync via CLI (`argocd app sync`) or UI — acts as a manual approval gate
- **Stage 3 (prod)**: Prod apps roll out gradually (10% maxUpdate = 1 app at a time)
- **Deletion**: When apps are removed, they're deleted in reverse order (prod → qa → dev)

**Requirements**: Progressive sync is a beta feature and must be enabled with `--enable-progressive-syncs` flag on the ApplicationSet controller.

## Two failure modes on display

- **Quiet zero-result** — `pull-request.yaml` runs successfully but its label filter matches no PRs, so it generates zero Applications. The ApplicationSet stays healthy.
- **Loud generator failure** — `git-broken` in `git.yaml` can't fetch its source, so the ApplicationSet itself goes red with an error condition.

## Source content scanned by Git generators

Lives at the repo root in [`../lightweight/`](../lightweight/) (outside this folder so ArgoCD's directory-source `recurse: false` default doesn't pick it up via the parent Application). Contents:

- `app-a/configmap.yaml`, `app-b/configmap.yaml` — single ConfigMaps that the Git Directories generator finds
