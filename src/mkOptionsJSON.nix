{
  pkgs,
  lib ? pkgs.lib,
  options,
  sourceMappings ? [],
  warningsAreErrors ? true,
  ...
}: let
  # Ensure that _module.args is not visible
  opts = options // {_module.args.internal = lib.mkForce true;};

  transformDeclarations = path: let
    matches = lib.filter (mapping: lib.hasPrefix mapping.source (toString path)) sourceMappings;
  in
    if matches != []
    then let
      mapping = lib.head matches;
      relativePath = lib.removePrefix mapping.source (toString path);
    in
      mapping.prefix + relativePath
    else path;
  optionsDoc = pkgs.nixosOptionsDoc {
    inherit warningsAreErrors;
    options = opts;
    transformOptions = opt: opt // {declarations = lib.map transformDeclarations opt.declarations;};
  };
in "${optionsDoc.optionsJSON}/share/doc/nixos/options.json"
