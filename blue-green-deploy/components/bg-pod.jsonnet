local bgGuestbook = std.extVar("__ksonnet/components")["bg-guestbook"];
local bgGuestbookSvc = bgGuestbook[0];
local bgGuestbookDeploy = bgGuestbook[1];

[
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "generateName": "blue-green-",
    "annotations": {
      "argocd.argoproj.io/hook": "Sync",
      "deploy-manifest": std.manifestJson(bgGuestbookDeploy),
      "svc-manifest": std.manifestJson(bgGuestbookSvc),
    },
  },
  "spec": {
    "serviceAccountName": "blue-green-sa",
    "restartPolicy": "Never",
    "containers": [
      {
        "name": "blue-green",
        "image": "argoproj/argoexec:latest",
        "command": ["bash", "-c"],
        "args": ["
            curl -L -o /usr/local/bin/kubectl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl &&
            chmod +x /usr/local/bin/kubectl &&
            curl -sSL -o /usr/local/bin/blue-green.sh https://raw.githubusercontent.com/argoproj/argocd-example-apps/master/blue-green-deploy/blue-green.sh &&
            chmod +x /usr/local/bin/blue-green.sh &&
            blue-green.sh
        "],
        "env": [
          {
            "name": "DEPLOY_MANIFEST",
            "valueFrom": {
              "fieldRef": {
                "fieldPath": "metadata.annotations['deploy-manifest']"
              }
            }
          },
          {
            "name": "SERVICE_MANIFEST",
            "valueFrom": {
              "fieldRef": {
                "fieldPath": "metadata.annotations['svc-manifest']"
              }
            }
          },
          // NOTE: app.kubernetes.io/instance will get injected into the hook object
          {
            "name": "APPNAME",
            "valueFrom": {
              "fieldRef": {
                "fieldPath": "metadata.labels['app.kubernetes.io/instance']"
              }
            }
          }
        ]
      }
    ],
  }
},
// RBAC to allow the blue-green pod privileges to manipulate deployments and services
{
	"apiVersion": "v1",
	"kind": "ServiceAccount",
	"metadata": {
		"name": "blue-green-sa"
	}
},
{
	"apiVersion": "rbac.authorization.k8s.io/v1",
	"kind": "Role",
	"metadata": {
		"name": "blue-green-role"
	},
	"rules": [
		{
			"apiGroups": [
				"apps",
        "extensions"
			],
			"resources": [
				"deployments",
			],
			"verbs": [
        "list",
        "get",
				"create",
				"update",
				"patch",
				"delete",
			]
		},
		{
			"apiGroups": [
				""
			],
			"resources": [
				"services"
			],
			"verbs": [
        "list",
        "get",
				"create",
				"update",
				"patch",
				"delete",
			]
		}
	]
},
{
  "apiVersion": "rbac.authorization.k8s.io/v1",
  "kind": "RoleBinding",
  "metadata": {
    "name": "blue-green-rolebinding"
  },
  "roleRef": {
    "apiGroup": "rbac.authorization.k8s.io",
    "kind": "Role",
    "name": "blue-green-role"
  },
  "subjects": [
    {
      "kind": "ServiceAccount",
      "name": "blue-green-sa"
    }
  ]
}
]