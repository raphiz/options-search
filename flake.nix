{
  description = "Simple nix documentation generator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs ["x86_64-linux" "x86_64-darwin" "aarch64-darwin" "aarch64-linux"]
      (system:
        function (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }));
  in {
    packages = forAllSystems (pkgs: {
      default =
        (import ./doc.nix)
        {
          inherit pkgs;
          modules = [./example.nix];
        };
    });
  };
}
