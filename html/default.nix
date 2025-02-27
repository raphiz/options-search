{
  pkgs,
  options ? null,
  modules ? null,
  title ? "Documentation",
  ...
}:
assert pkgs.lib.assertMsg ((options != null) != (modules != null)) "Either `options` or `modules` must be provided"; let
  inherit (pkgs) lib;
  opts =
    (
      if (options != null)
      then options
      else
        (lib.evalModules {
          inherit modules;
          specialArgs = {inherit pkgs;};
        })
        .options
    )
    # Ensure that _module.args is not visible
    // {_module.args.internal = lib.mkForce true;};

  optionsDoc = pkgs.nixosOptionsDoc {
    options = opts;
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
