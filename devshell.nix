{
  self,
  system,
  pkgs,
  ...
}: let
  sourceMappings = self.lib.mkFlakeSourceMappings {
    flake = self;
    inputs = ["nixpkgs" "devshell"];
  };

  exampleNixosHost = let
    optionsJSON = self.lib.mkOptionsJSON {
      inherit pkgs sourceMappings;
      inherit (self.nixosConfigurations.example) options;
    };
  in {
    package = self.lib.mkOptionsSearch {
      inherit pkgs optionsJSON;
      name = "options-search-nixos";
    };
    html = self.lib.optionsDocHtml {
      inherit pkgs optionsJSON;
    };
  };
in
  self.inputs.devshell.legacyPackages.${system}.mkShell ({options, ...}: let
  in {
    imports = [self.nixosModules.options-search];
    options-search.sourceMappings = sourceMappings;
    options-search.name = "options-search-devshell";
    name = "options-search";
    devshell.startup.htmlDocs.text = ''
      echo "Here are links to the HTML documentation"
      echo "- this dev shell: ${options.options-search.html.value}"
      echo "- example NixOS host: ${exampleNixosHost.html}/index.html"
    '';

    commands = [
      {
        package = exampleNixosHost.html;
        help = "List and describe the options for an example nixos host";
      }
    ];
  })
