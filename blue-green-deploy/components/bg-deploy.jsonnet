local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["bg-deploy"];
[
   {
      "apiVersion": "v1",
      "kind": "Service",
      "metadata": {
         "name": params.name,
         "annotations": {
            "argocd.argoproj.io/workflow-sync": "blue-green",
            "argocd.argoproj.io/workflow-param.blue-green.service-name": params.name,
            "argocd.argoproj.io/workflow-param.blue-green.new-service-manifest": "{{manifest}}",
         },
      },
      "spec": {
         "ports": [
            {
               "port": params.servicePort,
               "targetPort": params.containerPort
            }
         ],
         "selector": {
            "app": params.name
         },
         "type": params.type
      }
   },
   {
      "apiVersion": "apps/v1beta2",
      "kind": "Deployment",
      "metadata": {
         "name": params.name,
         "annotations": {
            "argocd.argoproj.io/workflow-sync": "blue-green",
            "argocd.argoproj.io/workflow-param.blue-green.deployment-name": params.name,
            "argocd.argoproj.io/workflow-param.blue-green.new-deployment-manifest": "{{manifest}}",
         },
      },
      "spec": {
         "replicas": params.replicas,
         "selector": {
            "matchLabels": {
               "app": params.name
            },
         },
         "template": {
            "metadata": {
               "labels": {
                  "app": params.name
               }
            },
            "spec": {
               "containers": [
                  {
                     "image": params.image,
                     "name": params.name,
                     "ports": [
                     {
                        "containerPort": params.containerPort
                     }
                     ]
                  }
               ]
            }
         }
      }
   }
]
