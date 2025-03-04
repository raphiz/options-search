lib_: {
  pkgs,
  optionsJSON,
  name ? "options-search",
}:
pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = [pkgs.jq pkgs.fzf pkgs.mdcat];
  text = ''
    jq -r 'keys[]' ${optionsJSON} | fzf "$@" --preview 'jq -r --arg key {-1} -f ${./format_options.jq} ${optionsJSON} | mdcat'
  '';
}
