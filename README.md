# Nix Modules option search

## Example usage

```nix
{
  exampleCli = inputs.options-search.lib.mkOptionsSearch {
    inherit pkgs;
    # you can also use `options` instead of `modules`
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

## Credits

* Based upon the ideas and code of [home-manager-option-search](https://mipmip.github.io/home-manager-option-search/).
* Based on parts of [nixos-render-docs](https://github.com/NixOS/nixpkgs/blob/master/pkgs/tools/nix/nixos-render-docs/src/nixos_render_docs)
* Idea inspired by [Alain Lehmann](https://github.com/ciderale)
