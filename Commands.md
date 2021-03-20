kubectl create ns guestbook
kc create ns helm-guestbook
kc create ns prod-kustomize-guestbook
kc create ns dev-kustomize-guestbook


argocd app create guestbook \
--repo https://github.com/radtac-craft/argocd-example-apps.git \
--path guestbook \
--dest-server https://kubernetes.default.svc \
--dest-namespace guestbook

argocd app sync guestbook
argocd app wait guestbook --sync


argocd app create helm-guestbook \
--repo https://github.com/radtac-craft/argocd-example-apps.git \
--path helm-guestbook \
--dest-server https://kubernetes.default.svc \
--dest-namespace helm-guestbook

argocd app sync helm-guestbook
argocd app wait helm-guestbook --sync

KUSTOMIZE -

PROD:
argocd app create prod-kustomize-guestbook \
--repo https://github.com/radtac-craft/argocd-example-apps.git \
--path kustomize-guestbook/overlays/prod \
--dest-server https://kubernetes.default.svc \
--dest-namespace prod-kustomize-guestbook \
--revision HEAD

argocd app sync prod-kustomize-guestbook
argocd app wait prod-kustomize-guestbook --sync

DEV:
argocd app create dev-kustomize-guestbook \
--repo https://github.com/radtac-craft/argocd-example-apps.git \
--path kustomize-guestbook/overlays/dev \
--dest-server https://kubernetes.default.svc \
--dest-namespace dev-kustomize-guestbook \
--revision dev

argocd app sync dev-kustomize-guestbook
argocd app wait dev-kustomize-guestbook --sync