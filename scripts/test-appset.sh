#!/bin/bash

argocd app delete applicationset --cascade=false --grpc-web
kubectl delete applicationset demo-apptest --cascade=orphan -n argocd
argocd app delete test-test1 --cascade=false --grpc-web
argocd app delete test-test2 --cascade=false --grpc-web
