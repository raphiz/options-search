{
  config,
  pkgs,
  lib,
  ...
}: let
in {
  options.example = {
    enable = lib.mkEnableOption "Enable example module";
    config = lib.mkOption {
      type = lib.types.bool;
      description = "This is some **markdown** description";
      example = false;
      default = true;
    };
    stuff = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Configure stuff";
    };
  };
}
