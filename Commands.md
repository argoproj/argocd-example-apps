kubectl create ns guestbook
kc create ns helm-guestbook
kc create ns prod-kustomize-guestbook
kc create ns dev-kustomize-guestbook


argocd app create guestbook \
--repo https://github.com/radtac-craft/argocd-example-apps.git \
--path guestbook \
--dest-server https://kubernetes.default.svc \
--dest-namespace guestbook


argocd app create helm-guestbook \
--repo https://github.com/radtac-craft/argocd-example-apps.git \
--path helm-guestbook \
--dest-server https://kubernetes.default.svc \
--dest-namespace helm-guestbook

KUSTOMIZE -

PROD:
argocd app create prod-kustomize-guestbook \
--repo https://github.com/radtac-craft/argocd-example-apps.git \
--path kustomize-guestbook/overlays/prod \
--dest-server https://kubernetes.default.svc \
--dest-namespace prod-kustomize-guestbook


DEV:
argocd app create dev-kustomize-guestbook \
--repo https://github.com/radtac-craft/argocd-example-apps.git \
--path kustomize-guestbook/overlays/dev \
--dest-server https://kubernetes.default.svc \
--dest-namespace dev-kustomize-guestbook
