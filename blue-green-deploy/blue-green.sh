#!bin/bash

DEPLOYMENT_NAME=$(echo "${DEPLOY_MANIFEST}" | jq -r '.metadata.name')
SERVICE_NAME=$(echo "${SERVICE_MANIFEST}" | jq -r '.metadata.name')

# 1. Check if the deployment exists. If it doesn't exist, this is the initial deployment and we
# can simply deploy without blue-green. Add the app label using jq
out=$(kubectl get --export -o json deployment.apps/${DEPLOYMENT_NAME} 2>&1)
if [ $? -ne 0 ]; then
  if [[ "${out}" =~ "NotFound" ]] ; then
    echo "Initial deployment"
    echo ${DEPLOY_MANIFEST} | \
      jq ".metadata.labels += {\"app.kubernetes.io/instance\": \"${APPNAME}\"}" | \
      kubectl apply -o yaml -f - || exit 1
    echo ${SERVICE_MANIFEST} | \
      jq ".metadata.labels += {\"app.kubernetes.io/instance\": \"${APPNAME}\"}" | \
      kubectl apply -o yaml -f - || exit 1
    exit 0
  fi
  echo "Failed to get deployment: ${out}"
  exit 1
fi
ORIGINAL_DEPLOY_MANIFEST=$out

# 2. Clone the original, running deployment to a temporary deployment, with tweaks to its name and
# selectors. The jq command carries over all labels and selectors and appends the `-temp` suffix.
TMP_DEPLOYMENT_NAME="${DEPLOYMENT_NAME}-temp"
echo ${ORIGINAL_DEPLOY_MANIFEST} | jq -r '.metadata.name+="-temp" |
  .spec.template.metadata.labels += (.spec.template.metadata.labels | to_entries | map(.value+="-temp") | from_entries) |
  .spec.selector.matchLabels += (.spec.selector.matchLabels | to_entries | map(.value+="-temp") | from_entries)' |
  kubectl apply -f -

# 3. Wait for cloned deployment to become ready.
sleep 2
echo "Waiting for successful rollout of new (temporary) deployment"
kubectl rollout status --watch=true deployments.apps/${TMP_DEPLOYMENT_NAME} || exit 1
echo "Rollout of temporary deployment successful"

# 4. Patch the service object such that all traffic is redirected to the cloned, temporary
# deployment. After this step, the original deployment will no longer be receiving traffic.
kubectl get service ${SERVICE_NAME} --export -o json | \
  jq '.spec.selector = (.spec.selector | with_entries(.value+="-temp"))' |
  kubectl apply -f - || exit 1
sleep 5 # Sleep slightly to allow iptables to get propagated to all nodes in the cluster

# 5. Update the original deployment (now receiving no traffic) with the new manifest
echo "Updating original deployment"
echo ${DEPLOY_MANIFEST} | \
  jq ".metadata.labels += {\"app.kubernetes.io/instance\": \"${APPNAME}\"}" | \
  kubectl apply -f - || exit 1

# 6. Wait for the new deployment to become complete
sleep 2
echo "Waiting for successful rollout of new deployment"
kubectl rollout status --watch=true deployments.apps/${DEPLOYMENT_NAME} || exit 1
echo "Rollout of new deployment successful"

# dummy wait step for demo purposes
echo "sleeping for 30 seconds"
sleep 30

# 7. Apply the new service object. Traffic will be redirected to the new version of the deployment
echo "Updating original service object"
echo ${SERVICE_MANIFEST} | \
  jq ".metadata.labels += {\"app.kubernetes.io/instance\": \"${APPNAME}\"}" | \
  kubectl apply -f - || exit 1

sleep 10
# 8. Remove the cloned deployment, which is no longer receiving any traffic
echo "Deleting ephemeral deployment"
kubectl delete deployments/${TMP_DEPLOYMENT_NAME} --ignore-not-found=true || exit 1
