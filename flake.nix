{
  description = "Simple nix documentation generator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    systems.url = "github:nix-systems/default";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    systems,
    ...
  }: let
    forEachSystem = nixpkgs.lib.genAttrs (import systems);
  in {
    # TODO: Add support to run it as follows:
    # options-search .#nixosConfigurations.example
    #
    # nix eval --json .#nixosConfigurations.example.options
    # not sure if it makes sense for nixosModules - it does not work in many cases...
    # > nix eval --json .#nixosModules.example --impure --apply 'module: let pkgs = import <nixpkgs> {}; in (pkgs.lib.evalModules {modules=[module];}).options'
    # devshells would also be nice but I don't think that there is a standard way to get this - maybe for devshell.nix via .#devShells.<system>.default.passthru.config?
    lib = {
      optionsDocHtml = import ./html;
      mkOptionsSearch = import ./cli;
      mkFlakeSourceMappings = import ./mkFlakeSourceMappings.nix;
    };

    devShells = forEachSystem (system: {
      default = import ./devshell.nix {
        inherit self system;
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      };
    });

    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./example/nixosHost.nix
      ];
    };

    nixosModules = import ./modules {};
  };
}
