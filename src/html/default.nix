_lib: {
  pkgs,
  optionsJSON,
  title ? "Documentation",
}:
pkgs.runCommand "options-doc-html" {
  buildInputs = with pkgs; [
    python3Packages.jinja2
    python3Packages.markdown-it-py
  ];
} ''
  mkdir -p $out
  python ${./build.py} ${optionsJSON} ${./index.html} "${title}" $out/index.html
''
