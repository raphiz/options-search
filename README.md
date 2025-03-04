# Nix Modules option search

Want to try it out? Run the devshell:

```bash
nix develop github:raphiz/options-search
# you will be greeted with further instructions
```

## Example usage

First, add this flake as an input to your flake:

```nix
  inputs = {
    options-search.url = "github:raphiz/options-search";
  }
```

then import the module

```nix
nixpkgs.lib.modules.evalModules { # or your module-system function of choice, eg. nixpkgs.lib.nixosSystem
    modules = [
      inputs.options-search.nixosModules.default
    ];
};
```

Thats it. You can now run the `options-search` in the evaluated module context.

For more examples, checkout the [devshell.nix file](./devshell.nix).

## Credits

* Based upon the ideas and code of [home-manager-option-search](https://mipmip.github.io/home-manager-option-search/).
* Based on parts of [nixos-render-docs](https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/nix/nixos-render-docs/src/nixos_render_docs)
* Idea inspired by [Alain Lehmanns nix-option-search](https://github.com/ciderale/nix-option-search)
