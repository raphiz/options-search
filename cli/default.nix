{
  pkgs,
  options ? null,
  modules ? null,
  name ? "options-search",
  sourceMappings ? [],
  warningsAreErrors ? true,
  ...
}:
assert pkgs.lib.assertMsg ((options != null) != (modules != null)) "Either `options` or `modules` must be provided"; let
  inherit (pkgs) lib;
  opts =
    (
      if (options != null)
      then options
      else (lib.evalModules {inherit modules;}).options
    )
    # Ensure that _module.args is not visible
    // {_module.args.internal = lib.mkForce true;};

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

  optionsJson = "${optionsDoc.optionsJSON}/share/doc/nixos/options.json";
  showCommand = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = [pkgs.jq pkgs.fzf pkgs.mdcat];
    text = ''
      jq -r 'keys[]' ${optionsJson} | fzf "$@" --preview 'jq -r --arg key {-1} -f ${./format_options.jq} ${optionsJson} | mdcat'
    '';
  };
in
  showCommand
