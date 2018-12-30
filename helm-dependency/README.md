# Helm Dependencies

This example application demonstrates how an OTS (off-the-shelf) helm chart can be retrieved and
pinned to a specific helm sem version from an upstream helm repository, and customized using a custom
values.yaml in the private git repository.

In this example, the wordpress application is pulled from the stable helm repo, and pinned to v5.0.2:

```yaml
dependencies:
- name: wordpress
  version: 5.0.2
  repository: https://kubernetes-charts.storage.googleapis.com
```

A custom values.yaml is used to customize the parameters of the wordpress helm chart:

```yaml
wordpress:
  wordpressPassword: foo
  mariadb:
    db:
      password: bar
    rootUser:
      password: baz
```
