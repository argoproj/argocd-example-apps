{
  inputs.nixhelm.url = "github:farcaller/nixhelm";
  inputs.kubegen.url = "github:farcaller/nix-kube-generators";

  outputs = { self, nixpkgs, nixhelm, kubegen, flake-utils }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      kubelib = kubegen.lib { inherit pkgs; };

      addResources = yamlObjects: resources: builtins.foldl'
        (acc: y: acc ++ [ y ])
        resources
        yamlObjects;

      # You can define k8s objects using standard nix syntax
      configMap = {
        apiVersion = "v1";
        kind = "ConfigMap";
        metadata.name = "website";
        data."index.html" = ''
          <html>
            <body>
              <h1>Hello, nix world!</h1>
            </body>
          </html>
        '';
      };
    in
    {
      packages.kubernetesConfiguration = pkgs.lib.pipe
        {
          name = "nginx";
          # nixhelm provides a repository of various public helm charts converted to nix
          chart = nixhelm.chartsDerivations.${system}.bitnami.nginx;
          namespace = "default";
          values = {
            replicaCount = 2;
            revisionHistoryLimit = 3;
            staticSiteConfigmap = configMap.metadata.name;
          };
        } [
        # lib.pipe is a handy function to run the processing over several functions in a sequence.
        # The final output must gnerate a YAML file.
        kubelib.buildHelmChart
        builtins.readFile
        kubelib.fromYAML
        (addResources [configMap])
        kubelib.mkList
        kubelib.toYAMLFile
      ];
    });
}
