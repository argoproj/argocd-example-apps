# nix

[nix](https://nixos.org/) is a tool that takes a unique approach to package
management and system configuration.

This setup is based on the [NixCon 2023 talk](https://www.youtube.com/watch?v=SEA1Qm8K4gY).

## Set up the argo-cd installation for nix support

This setup uses the stock `nixos/nix:latest` image without any modifications.
That requires some changes in runtime, as nix cannot run as user 999 our of the
box.

Add the following bits to the values.yaml of your helm deployment:

```yaml
repoServer:
  volumes:
    - name: nix-cmp-config
      configMap:
        name: nix-cmp-config
    - name: nix-cmp-tmp
      emptyDir: {}
    - name: nix-cmp-nix
      emptyDir: {}
    - name: nix-cmp-home
      emptyDir: {}
  initContainers:
    - name: nix-bootstrap
      # the init container copies the whole nix store and profiles into the
      # temporary volume and makes sure the permissions are correct
      command:
        - "sh"
        - "-c"
        - "cp -a /nix/* /nixvol && chown -R 999 /nixvol/*"
      image: nixos/nix:latest
      # the image will always be updated at init step, so the one in the
      # extraContainers must have the policy of Never to always be the same
      # exact image.
      imagePullPolicy: Always 
      volumeMounts:
        - mountPath: /nixvol
          name: nix-cmp-nix
  extraContainers:
    - name: nix-cmp-plugin
      command:
        - /var/run/argocd/argocd-cmp-server
      image: nixos/nix:latest
      imagePullPolicy: Never
      securityContext:
        runAsNonRoot: true
        runAsUser: 999
      volumeMounts:
        - mountPath: /var/run/argocd
          name: var-files
        - mountPath: /home/argocd/cmp-server/plugins
          name: plugins
        - mountPath: /home/argocd/cmp-server/config/plugin.yaml
          subPath: plugin.yaml
          name: nix-cmp-config
        - mountPath: /etc/passwd
          subPath: passwd
          name: nix-cmp-config
        - mountPath: /etc/nix/nix.conf
          subPath: nix.conf
          name: nix-cmp-config
        - mountPath: /tmp
          name: nix-cmp-tmp
        - mountPath: /nix
          name: nix-cmp-nix
        - mountPath: /home/nix
          name: nix-cmp-home
```

## Add the plugin ConfigMap:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nix-cmp-config
  namespace: argocd
data:
  nix.conf: |
    build-users-group = nixbld
    sandbox = false
    experimental-features = nix-command flakes
    substituters = https://cache.nixos.org https://nixhelm.cachix.org
    trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nixhelm.cachix.org-1:esqauAsR4opRF0UsGrA6H3gD21OrzMnBBYvJXeddjtY=
  passwd: |
    nix:x:999:30000:Nix build user 1:/home/nix:/bin/false
    root:x:0:0::/root:/bin/bash
  plugin.yaml: |
    apiVersion: argoproj.io/v1alpha1
    kind: ConfigManagementPlugin
    metadata:
      name: nix-cmp-plugin
    spec:
      discover:
        fileName: flake.nix
      generate:
        command:
        - sh
        - "-c"
        - cat result
      init:
        command:
        - sh
        - "-c"
        - |
          export OUTPUT="${ARGOCD_ENV_NIX_OUTPUT:-kubernetesConfiguration}"
          echo -ne "Building for $OUTPUT\n" >/dev/stderr
          if [ "$PARAM_VALUES" != "" ]; then
            echo -ne "With values\n" >/dev/stderr
            echo "$PARAM_VALUES" > values.json
            nix-shell -p git --run ''git add values.json''
          fi
          if [ "$PARAM_IMPURE" == "true" ]; then
            echo -ne "With impure\n" >/dev/stderr
            IMPURE_FLAG="--impure"
          else
            IMPURE_FLAG=""
          fi
          nix build $IMPURE_FLAG ".#${OUTPUT}"
      lockRepo: true
      name: nix-cmp-plugin
      version: v1.0
```

## Create a nix-based application

```
argocd app create simple-nginx \
    --repo https://github.com/argoproj/argocd-example-apps \
    --path plugins/nix \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace default
```
