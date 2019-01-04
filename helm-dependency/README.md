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

### Subchart Note

The wordpress chart referenced in this example contains a subchart for mariadb as specified in the requirements.yaml file of the wordpress chart:
```yaml
- name: mariadb
  version: 5.x.x
  repository: https://kubernetes-charts.storage.googleapis.com/
  condition: mariadb.enabled
  tags:
    - wordpress-database
```

In order to disable this chart, you must set the value to false for both `mariadb.enabled` and `wordpress.mariadb.enabled`. The first is used by the mariadb subchart condition field, the second is used by the wordpress chart deployment template. An example demonstration is available in the values-nomaria.yaml file:
```yaml
mariadb:
  enabled: false

wordpress:
  wordpressPassword: foo
  mariadb:
    enabled: false
  externalDatabase:
    host: localhost
    user: bn_wordpress
    password: ""
    database: bitnami_wordpress
    port: 3306
```