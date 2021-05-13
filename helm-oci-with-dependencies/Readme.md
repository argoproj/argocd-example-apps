ArgoCD V2.0.1
from folder argocd-example-apps, execute the following 

helm chart save helm-values localhost:5000/myrepo/helm-values:1.0.0
ref:     localhost:5000/myrepo/helm-values:1.0.0
digest:  54cd9f79f0e383f02fc2408b4a3ba52e035e4a6c50e6dfbd5f022d715b572bff
size:    320 B
name:    helm-values
version: 1.0.0
1.0.0: saved

helm chart push localhost:5000/myrepo/helm-values:1.0.0
The push refers to repository [localhost:5000/myrepo/helm-values]
ref:     localhost:5000/myrepo/helm-values:1.0.0
digest:  54cd9f79f0e383f02fc2408b4a3ba52e035e4a6c50e6dfbd5f022d715b572bff
size:    320 B
name:    helm-values
version: 1.0.0

argocd repo list
TYPE  NAME  REPO  INSECURE  OCI  LFS  CREDS  STATUS  MESSAGE

argocd repo add localhost:5000/myrepo --type helm --name myrepo --enable-oci --username myuser --password mypass
repository 'localhost:5000/myrepo' added

argocd app create mayoci --repo https://github.com/mayzhang2000/argocd-example-apps.git --path helm-oci-with-dependencies --dest-server https://kubernetes.default.svc --dest-namespace default
application 'mayoci' created



