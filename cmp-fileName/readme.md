This is an example of using cmp.

### create a docker image for your cmp server
```
docker build -f Dockerfile.maycmp -t <your doccker path>/maycmpserver:cmp .
```

### plugin-withFilename-config
This is the plugin configuration file. It uses discover.fileName by matching with this pattern.

### Changes in argocd-repo-server.yaml.
added a new side car which uses the docker image built above.
```
      containers:
      - name: may
        command: [/var/run/argocd/argocd-cmp-server]
        image: docker.intuit.com/dev/deploy/argo-cd-tools/service/maycmpserver:cmp
        volumeMounts:
          - mountPath: /var/run/argocd
            name: var-files
          - mountPath: /home/argocd/cmp-server/plugins
            name: plugins
          - mountPath: /tmp
            name: tmp-dir
```

### Create an app using this plugin
```
argocd app create maycmp2 --repo https://github.com/mayzhang2000/argocd-example-apps.git --path cmp-fileName --dest-server https://kubernetes.default.svc --dest-namespace default --config-management-plugin cmp-fileName
```
### Trouble shooting
```	
k exec -it argocd-repo-server-88dc68b5c-rmkmx -c argocd-repo-server sh
```
