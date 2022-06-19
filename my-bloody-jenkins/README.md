# My Bloody Jenkins

## Prerequisites Details
* Kubernetes 1.8+

## Chart Details
The chart will do the following:
* Deploy [My Bloody Jenkins](https://github.com/odavid/my-bloody-jenkins)
* Manage Configuration in a dedicated ConfigMap
* Configures Jenkins to use a default [k8s jenkins cloud](https://plugins.jenkins.io/kubernetes)
* Optionally expose Jenkins with [Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
* Manages a [Persistent Volume Claim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) for Jenkins Storage
* Optionally mount extenral [secrets](https://kubernetes.io/docs/concepts/configuration/secret/) as volumes to be used within the configuration [See docs](https://github.com/odavid/my-bloody-jenkins/pull/102)
* Optionally mount external [configMaps](https://kubernetes-v1-4.github.io/docs/user-guide/configmap/) to be used as configuration data sources [See docs](https://github.com/odavid/my-bloody-jenkins/pull/102)
* Optionally configures [rbac](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) and a dedicated [service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)


## Installing the Chart
First add the following repo:

```shell
helm repo add odavid https://odavid.github.io/k8s-helm-charts
```

To install the chart with the release name `jenkins`:
```shell
helm install --name jenkins odavid/my-bloody-jenkins
```

To install the chart with a custom configuration values.yml
```shell
helm install --name jenkins odavid/my-bloody-jenkins -f <valueFiles>
```

## Upgrading the Release
To install the chart with a custom configuration values.yml
```shell
helm upgrade jenkins odavid/my-bloody-jenkins -f <valueFiles>
```

## Deleting the Chart
```shell
helm delete jenkins
```

## Docker Image
By default the chart uses the [latest release of `odavid/my-bloody-jenkins`](https://hub.docker.com/r/odavid/my-bloody-jenkins/tags/) image.
The Helm Chart provides a way to use different repo or tags:
* `image.repository` - by default `odavid/my-bloody-jenkins`
* `image.tag`
* `image.pullPolicy` - by default `IfNotPresent`
* `image.imagePullSecret` - not set by default


## CPU and Memory Resources
The Helm chart comes with support for configured resource requests and limits.
By default these values are commented out.
It is __highly__ recommended to change this behavior on a production deployment. Also the Helm Chart provides a way to control Jenkins Java Memory Opts. When using Jenkins in production, you will need to set the values that suites your needs.

## Persistence
By default the helm chart allocates a 20gb volume for jenkins storage.
The chart provides the ability to control:
* `persistence.jenkinsHome.enabled` - if set to false, jenkins home will be using empty{} volume instead of persistentVolumeClaim. Default is `true`
* `persistence.jenkinsHome.size` - the managed volume size
* `persistence.jenkinsHome.storageClass` - If set to `"-"`, then storageClass: `""`, which disables dynamic provisioning. If undefined (the default) or set to null, no storageClass spec is set, choosing the default provisioner. (gp2 on AWS, standard on GKE, AWS & OpenStack)
* `persistence.jenkinsHome.existingClaim` - if provided, jenkins storage will be stored on an manually managed persistentVolumeClaim
* `persistence.jenkinsHome.annotations` - annotations that will be added to the managed persistentVolumeClaim

## Secrets
My Bloody Jenkins natively supports [environment variable substitution](https://github.com/odavid/my-bloody-jenkins#environment-variable-substitution-and-remove-master-env-vars) within its configuration files.
The Helm Chart provides a simple way to map [k8s secrets] in dedicated folders that will be later on used as environment variables datasource.

In order to use this feature, you will need to create external secrets and then use: `envSecrets` property to add these secrets to the search order.
For example:
```shell
echo -n 'admin' > ./username
echo -n 'password' > ./password
kubectl create secret generic my-jenkins-secret --from-file=./username --from-file=./password
```

Then add this secret to values.yml:
```yaml
envSecrets:
    - my-jenkins-secret
```
Now, you can refer these secrets as environmnet variables:
* `MY_JENKINS_SECRET_USERNAME`
* `MY_JENKINS_SECRET_PASSWORD`

See [Support multiple data sources and secrets from files](https://github.com/odavid/my-bloody-jenkins/pull/102) for more details

The chart also support creating a dedicated k8s secret, which all its keys will become `JENKINS_SECRET_<KEY>`. In order to use it, you will need to provided a key/value dict under the `secrets` value

## Managed Configuration and additional ConfigMaps
My Bloody Jenkins natively supports watching multiple config data sources and merge them into one config top to bottom
The Helm Chart provides a way to define a `managedConfig` yaml within the chart values.yml as well as add additional external `configMaps` that will be merged/override the default configuration.

See [Support multiple data sources and secrets from files](https://github.com/odavid/my-bloody-jenkins/pull/102) for more details
The `managedConfig` is mounted as `/var/jenkins_managed_config/jenkins-config.yml` and contains the `managedConfig` yaml contents

Additional `configMaps` list are mounted as `/var/jenkins_config/<ConfigMapName>` within the container and are merged with the `managedConfig`

## Default K8S Jenkins Cloud for provisioning slaves within k8s
By default the Helm Chart Configures a [kubernetes cloud](https://plugins.jenkins.io/kubernetes) with a simple jnlp slave template.
For disabling this behavior, you need to set `defaultK8sCloud.enabled` to `false`
The following attributes can control the default template:
* `defaultK8sCloud.name` - the name of the k8s cloud - default (`k8s`)
* `defaultK8sCloud.labels` - list of agent labels that are used to provision the node - e.g. ```node(labels){}``` pipeline step - default (`["generic"]`)
* `defaultK8sCloud.jvmArgs` - JVM Args for the JNLP Slave - default (`"-Xmx1g"`)
* `defaultK8sCloud.remoteFs` - JNLP Remote FS - default (`"/home/jenkins"`)
* `defaultK8sCloud.image` - JNLP Slave Image - default (`"odavid/jenkins-jnlp-slave:latest"`)

## Configuration

The following table lists the configurable parameters of the chart and their default values.

|         Parameter         |           Description             |                         Default                          |
|---------------------------|-----------------------------------|----------------------------------------------------------|
| `managedConfig` | `My Bloody Jenkins` Configuration yaml - See [Configuration Reference](https://github.com/odavid/my-bloody-jenkins#configuration-reference) |
| `defaultK8sCloud.enabled` | If `true` a default k8s jenkins cloud will be configured to enable automatic slave provisioning | `true`
| `defaultK8sCloud.name` | The name of the default k8s cloud | `k8s`
| `defaultK8sCloud.labels` | List of labels that mark the k8s provisioned slaves, use `node(label){}` within pipeline | `["generic"]`
| `defaultK8sCloud.jvmArgs` | Default JVM Args to pass to the jnlp slave of the k8s cloud | `-Xmx1g`
| `defaultK8sCloud.remoteFs` | The remoteFS of the JNLP Slave | `/home/jenkins`
| `defaultK8sCloud.image` | The docker image of the JNLP Slave | `odavid/jenkins-jnlp-slave:latest`
| `image.repository`        | `My Bloody Jenkins` Docker Image       | `odavid/my-bloody-jenkins`
| `image.tag`               | `My Bloody Jenkins` Docker Image Tag       | `2.121.1-62`
| `image.pullPolicy`        | Image Pull Policy                 | `IfNotPresent`
| `image.imagePullSecrets`        | Docker registry pull secret       |
| `service.type`            | Service Type   | `LoadBalanacer`
| `service.externalTrafficPolicy` | externalTrafficPolicy |
| `service.annotations`        | Service Annotations       | `{}`
| `service.loadBalancerSourceRanges`        | Array Of IP CIDR ranges to whitelist (Only if service type is `LoadBalancer`) |
| `service.loadBalancerIP`        | Service Load Balancer IP Address (Only if service type is `LoadBalancer`) |
| `ingress.enabled`        | If `true` Ingress will be created      | `false`
| `ingress.httpProtocol`  |  Change to https if the ingress uses tls or you are using external tls termination using annotations | `http`
| `ingress.path`        | Ingress Path (Only if ingress is enabled)| `/`
| `ingress.additionalRules`        | Additional Ingress Rules| `[]` that will be appended to the actual ingress rule.
| `ingress.preAdditionalRules`        | Additional Ingress Rules| `[]` that will be pre-appended to the actual ingress rule. Useful when using alb ingress class with [actions](https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/ingress/annotation/#actions)
| `ingress.annotations`        | Ingress Annoations| `{}`
| `ingress.labels`        | Ingress Labels| `{}`
| `ingress.hostname`        | Ingress Hostname |
| `ingress.ingressClassName`        | Ingress Class Name | 
| `ingress.pathType`        | Ingress Path Type | `Prefix`
| `ingress.tls.secretName`        | Ingress TLS Secret Name - if provided, the ingress will terminate TLS using the certificate and private key in this secret. This setting is mutually exclusive with ingress.tls.certificate and ingress.tls.privateKey|
| `ingress.tls.certificate`        | Ingress TLS Certificate - if provided, the ingress will use this certificate. Use in conjunction with ingress.tls.privateKey|
| `ingress.tls.privateKey`        | Ingress TLS private key - if provided, the ingress will use this private key. Use in conjunction with ingress.tls.certificate |
| `rbac.create`        | If `true` - a ServiceAccount, and a Role will be created| `true`
| `rbac.createServiceAccount`        | If `createServiceAccount` = `false`, and `rbac.create` = `true`, the chart will only use the `rbac.serviceAaccountName` within RoleBindings | true
| `rbac.serviceAccountName`        | Ignored if createServiceAccount = true | `default`
| `rbac.serviceAccount.annotations`        | Specify ServiceAccount annotations | {}
| `rbac.clusterWideAccess`        | If `true` - A ClusterRole will be created instead of Role - relevant only if `rbac.create` is `true`| `false`
| `resources.requests.cpu` | Initial CPU Request  |
| `resources.requests.memory` | Initial Memory Request  |
| `resources.limits.cpu` | CPU Limit |
| `resources.limits.memory` | Memory Limit |
| `readinessProbe.timeoutSeconds` | Readiness Probe Timeout in seconds | `5`
| `readinessProbe.initialDelaySeconds` | Readiness Probe Initial Delay in seconds | `5`
| `readinessProbe.periodSeconds` | Readiness Probe - check for readiess every `X` seconds | `5`
| `readinessProbe.failureThreshold` | Readiness Probe - Mark the pod as not ready for traffic after `X` consecutive failures | `3`
| `livenessProbe.timeoutSeconds` | Liveness Probe Timeout in seconds | `5`
| `livenessProbe.initialDelaySeconds` | Liveness Probe Initial Delay in seconds - a high value since it takes time to start| `600`
| `livenessProbe.periodSeconds` | Liveness  Probe - check for liveness every `X` seconds | `5`
| `livenessProbe.failureThreshold` | Liveness Probe - Kill the pod after `X` consecutive failures | `3`
| `persistence.mountDockerSocket` | If `true` - `/var/run/docker.sock` will be mounted | `true`
| `persistence.jenkinsHome.enabled` | If `true` - Jenkins Storage will be persistent | `true`
| `persistence.jenkinsHome.existingClaim` | External Jenkins Storage PesistentVolumeClaim - if set, then no volume claim will be created by the Helm Chart|
| `persistence.jenkinsHome.annotations` | Jenkins Storage PesistentVolumeClaim annotations | `{}`
| `persistence.jenkinsHome.accessMode` | Jenkins Storage PesistentVolumeClaim accessMode | `ReadWriteOnce`
| `persistence.jenkinsHome.size` | Jenkins Storage PesistentVolumeClaim size | `20Gi`
| `persistence.jenkinsHome.storageClass` | External Jenkins Storage PesistentVolumeClaim | If set to `"-"`, then storageClass: `""`, which disables dynamic provisioning. If undefined (the default) or set to null, no storageClass spec is set, choosing the default provisioner. (gp2 on AWS, standard on GKE, AWS & OpenStack)
| `persistence.jenkinsWorkspace.enabled` | If `true` - Jenkins Workspace Storage will be persistent | `false`
| `persistence.jenkinsWorkspace.existingClaim` | External Jenkins Workspace Storage PesistentVolumeClaim - if set, then no volume claim will be created by the Helm Chart|
| `persistence.jenkinsWorkspace.annotations` | Jenkins Workspace Storage PesistentVolumeClaim annotations | `{}`
| `persistence.jenkinsWorkspace.accessMode` | Jenkins Workspace Storage PesistentVolumeClaim accessMode | `ReadWriteOnce`
| `persistence.jenkinsWorkspace.size` | Jenkins Workspace Storage PesistentVolumeClaim size | `8Gi`
| `persistence.jenkinsWorkspace.storageClass` | External Jenkins Workspace Storage PesistentVolumeClaim | If set to `"-"`, then storageClass: `""`, which disables dynamic provisioning. If undefined (the default) or set to null, no storageClass spec is set, choosing the default provisioner. (gp2 on AWS, standard on GKE, AWS & OpenStack)
| `podAnnotations` | Additional Pod Annotations | `{}`
| `persistence.volumes` | Additional volumes to be included within the Deployments |
| `persistence.mounts` | Additional mounts to be mounted to the container |
| `nodeSelector` | Node Selector | `{}`
| `tolerations` | Tolerations | `[]`
| `securityContxet` | Security Context for jenkins pod | `{}`
| `affinity` | Affinity | `{}`
| `env` | Additional Environment Variables to be passed to the container - format `key`: `value` |
| `secret` | A dict containing KEY/VALUE pairs. Each pair will become an environment variable `JENKINS_SECRET_<KEY>`, if the `secrets` dict is not empty a k8s secret will be created|
| `envSecrets` | List of external secret names to be mounted as env secrets - see [Docs](https://github.com/odavid/my-bloody-jenkins/pull/102) |
| `configMaps` | List of external config maps to be used as configuration files - see [Docs](https://github.com/odavid/my-bloody-jenkins/pull/102) |
| `jenkinsAdminUser` | The name of the admin user - must be a valid user within the [Jenkins Security Realm](https://github.com/odavid/my-bloody-jenkins#security-section)| `admin`
| `javaMemoryOpts` | Jenkins Java Memory Opts | `-Xmx256m`
| `useHostNetwork` | If true, jenkins master will use hostNetwork | `false`
| `jenkinsURL` | Set the jenkinsURL configuration. If not set and ingress is enabled, then jenkins URL is {{ .Values.ingress.httpProtocol }}://{{ .Values.ingress.hostname }}{{ .Values.ingress.path }} |
