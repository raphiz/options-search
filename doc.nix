{
  pkgs,
  options,
  title ? "Documentation",
  ...
}: let
  optionsDoc = pkgs.nixosOptionsDoc {
    inherit options;
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
