local bgGuestbook = std.extVar("__ksonnet/components")["bg-guestbook"];
local bgGuestbookSvc = bgGuestbook[0];
local bgGuestbookDeploy = bgGuestbook[1];
local parseYaml = std.native("parseYaml");
local bgWorkflow = parseYaml(importstr 'wf/bluegreen.yaml')[0];

[
  bgWorkflow + {
    spec +: {
      arguments +: {
        parameters : [
          {name: "deployment-name", value: bgGuestbookDeploy.metadata.name},
          {name: "service-name", value: bgGuestbookSvc.metadata.name},
          {name: "new-deployment-manifest", value: std.manifestJson(bgGuestbookDeploy)},
          {name: "new-service-manifest", value: std.manifestJson(bgGuestbookSvc)},
        ],
      },
    },
  }
]