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
    lib = import ./src/lib.nix;

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
        self.nixosModules.options-search
      ];
    };

    nixosModules = let
      options-search = import ./module.nix self.lib;
    in {
      inherit options-search;
      default = options-search;
    };
  };
}
