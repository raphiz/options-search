{
  flake,
  inputs,
}: let
  lockfileMappings = (builtins.fromJSON (builtins.readFile "${flake}/flake.lock")).nodes;
in (builtins.map (input: let
    source = "${flake.inputs.${input}}/";
  in {
    inherit source;
    prefix =
      if builtins.hasAttr input lockfileMappings
      then let
        locked = lockfileMappings.${input}.locked;
      in (
        if lockfileMappings.${input}.locked.type == "github"
        then "https://github.com/${locked.owner}/${locked.repo}/blob/${locked.rev}/"
        else source
        # TODO: Also support gitlab and sourcehut (both with host)
      )
      else builtins.warn "input ${input} passed to ${lockfileMappings} was not found in the flakes lockfile." source;
  })
  inputs)
