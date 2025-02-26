{
  pkgs,
  options,
  name ? "options-search",
  sourceMappings ? [],
  warningsAreErrors ? true,
  ...
}: let
  inherit (pkgs) lib;

  # TODO: support mappings derived via lockfile
  # but must not trigger lazy evaluation of inputs!
  # Ideally, just provide a "flake" and "thing should just work"
  # TODO: Log warnings for unknown flake input formats -> or just ignore?
  # sourceMappings = [
  #       {
  #         # TODO: magically derive via lockfile
  #         flakeInput = {
  #           inherit flake;
  #           name = "devshell";
  #         };
  #         # But can be done manually as well
  #         source = flake.inputs.devshell.outPath;
  #         prefix = "https://github.com/numtide/devshell/blob/${flake.inputs.devshell.rev}";
  #       }
  #       # TODO: Test "self"
  #       {
  #         source = flake.outPath;
  #         prefix = "";
  #       }
  #     ];

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
    options = options // {_module.args.internal = lib.mkForce true;};
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
