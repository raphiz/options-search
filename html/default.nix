{
  pkgs,
  options,
  title ? "Documentation",
  ...
}: let
  optionsDoc = pkgs.nixosOptionsDoc {
    options = options // {_module.args.internal = pkgs.lib.mkForce true;};
  };
in
  pkgs.runCommand "options-doc-html" {
    buildInputs = with pkgs; [
      python3Packages.jinja2
      python3Packages.markdown-it-py
    ];
  } ''
    mkdir -p $out
    python ${./build.py} ${optionsDoc.optionsJSON}/share/doc/nixos/options.json ${./index.html} "${title}" $out/index.html
  ''
