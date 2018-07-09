local env = std.extVar("__ksonnet/environments");
local params = std.extVar("__ksonnet/params").components["guestbook-ui"];
[
   {
      "apiVersion": "v1",
      "kind": "Service",
      "metadata": {
         "name": params.name
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
         "name": params.name
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
                    ],
                    // dummy readiness probe to slow down the rollout for demo/testing
                    "readinessProbe": {
                        "exec": {
                            "command": [ "sh", "-c", "exit 0" ],
                        },
                        "initialDelaySeconds": 30,
                        "periodSeconds": 120,
                    }
                  }
               ]
            }
         }
      }
   }
]
