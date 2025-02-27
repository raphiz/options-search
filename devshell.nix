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
  exampleModuleHtml = self.lib.optionsDocHtml {
    inherit pkgs sourceMappings;
    modules = [./example/module.nix];
  };
  exampleNixosHostHtml = self.lib.optionsDocHtml {
    inherit pkgs sourceMappings;
    inherit (self.nixosConfigurations.example) options;
  };
  exampleModuleCli = self.lib.mkOptionsSearch {
    inherit pkgs sourceMappings;
    modules = [./example/module.nix];
    name = "search-example-module";
  };
  exampleNixosHostCli = self.lib.mkOptionsSearch {
    inherit pkgs sourceMappings;
    inherit (self.nixosConfigurations.example) options;
    name = "search-example-nixos-host";
  };
in
  self.inputs.devshell.legacyPackages.${system}.mkShell ({options, ...}: let
    exampleDevshellCli = self.lib.mkOptionsSearch {
      inherit pkgs sourceMappings options;
      name = "search-example-devshell";
    };
  in {
    name = "options-search";
    devshell.startup.htmlDocs.text = ''
      echo "Here is are links to the HTML documentation"
      echo "- example module: ${exampleModuleHtml}/index.html"
      echo "- example NixOS host: ${exampleNixosHostHtml}/index.html"
    '';
    commands = [
      {
        package = exampleModuleCli;
        help = "List and describe the options of an example module";
      }
      {
        package = exampleNixosHostCli;
        help = "List and describe the options of an example nixos host";
      }
      {
        package = exampleDevshellCli;
        help = "List and describe the options for this devshell";
      }
    ];
  })
