{
  pkgs,
  modules,
  title ? "Documentation",
  ...
}: let
  suppressModuleArgsDocs = {lib, ...}: {
    options = {
      _module.args = lib.mkOption {
        internal = true;
      };
    };
    config._module.check = false;
  };
  eval = pkgs.lib.evalModules {
    modules =
      modules
      ++ [
        suppressModuleArgsDocs
      ];
  };

  optionsDoc = pkgs.nixosOptionsDoc {
    inherit (eval) options;
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
