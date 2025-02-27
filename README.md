# Nix Modules option search

Want to try it out? Run the devshell:

```bash
nix develop github:raphiz/options-search
# you will be greeted with further instructions
```

## Example usage

```nix
{
  exampleCli = inputs.options-search.lib.mkOptionsSearch {
    inherit pkgs;
    # you can also use `options` instead of `modules`, for example:
    # options = flake.nixosConfigurations.host.options;
    modules = [
      ./my-module.nix
    ];
    name = "example";
  };

  exampleHtml = inputs.options-search.lib.optionsDocHtml {
    inherit pkgs options;
    modules = [
        ./my-module.nix
    ];
  };
  # ...
}
```

For more examples, checkout the [devshell.nix file](./devshell.nix).

## Credits

* Based upon the ideas and code of [home-manager-option-search](https://mipmip.github.io/home-manager-option-search/).
* Based on parts of [nixos-render-docs](https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/nix/nixos-render-docs/src/nixos_render_docs)
* Idea inspired by [Alain Lehmann](https://github.com/ciderale)
