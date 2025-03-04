let
  lib = {
    mkOptionsJSON = import ./mkOptionsJSON.nix;
    optionsDocHtml = import ./html lib;
    mkOptionsSearch = import ./cli lib;
    mkFlakeSourceMappings = import ./mkFlakeSourceMappings.nix;
  };
in
  lib
