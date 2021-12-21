#!/bin/bash

argocd app delete applicationset --cascade=false --grpc-web
kubectl delete applicationsets test-appset --cascade=orphan -n argocd
argocd app delete demo-test1 --cascade=false --grpc-web
argocd app delete demo-test2 --cascade=false --grpc-web
