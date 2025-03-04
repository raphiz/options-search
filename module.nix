_lib: {
  options,
  lib,
  pkgs,
  ...
}: let
  cfg = options.options-search;
in {
  options.options-search = {
    options = lib.mkOption {
      description = "the options to use. will by default use the options of this module system instance";
      default = null; # null will use current instance. Can't specify that as default as it would lead to infinite
      defaultText = lib.literalExpression ''options'';
    };

    sourceMappings = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule ({...}: {
        options = {
          source = lib.mkOption {
            type = lib.types.str;
            description = "The source path for the mapping.";
          };
          prefix = lib.mkOption {
            type = lib.types.str;
            description = "The prefix associated with the source path.";
          };
        };
      }));
      default = [];
      description = "A list containing source and prefix mappings.";
    };

    name = lib.mkOption {
      default = "options-search";
      description = "";
      type = lib.types.str;
    };

    addPackageToPath = lib.mkOption {
      default = true;
      description = "Whether to add the options-search executable to the path (supports: nixos, home-manager, devenv, devshell.nix)";
      type = lib.types.bool;
    };

    html = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      description = ''This option contains the html'';
    };

    json = lib.mkOption {
      type = lib.types.path;
      readOnly = true;
      description = ''This option contains the options json'';
    };

    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      description = ''This option contains the cli'';
    };
  };

  config = {
    options-search = {
      json = _lib.mkOptionsJSON {
        inherit pkgs;
        sourceMappings = cfg.sourceMappings.value;
        options =
          if cfg.options.value != null
          then cfg.options.value
          else options;
      };
      html =
        _lib.optionsDocHtml {
          inherit pkgs;
          optionsJSON = cfg.json.value;
        }
        + "/index.html";
      package = _lib.mkOptionsSearch {
        inherit pkgs;
        optionsJSON = cfg.json.value;
        name = cfg.name.value;
      };
    };

    # hacky conditionals ahead! See https://discourse.nixos.org/t/conditionally-set-attribute/28864/8

    # add package for nixos
    ${
      if (options ? system.nixos.release && options ? environment.systemPackages)
      then "environment"
      else null
    } =
      lib.mkIf cfg.addPackageToPath.value {systemPackages = [cfg.package.value];};

    # add package for home-manager
    ${
      if (options ? programs.home-manager.enable && options ? home.packages)
      then "home"
      else null
    } =
      lib.mkIf cfg.addPackageToPath.value {packages = [cfg.package.value];};

    # Set command for devenv.nix
    ${
      if (options ? devshell && options ? commands)
      then "commands"
      else null
    } = lib.mkIf cfg.addPackageToPath.value [
      {
        package = cfg.package.value;
        help = "List and describe all available devshell options";
      }
    ];

    # add package for devenv.sh
    ${
      if (options ? devenv && options ? packages)
      then "packages"
      else null
    } =
      lib.mkIf cfg.addPackageToPath.value [cfg.package.value];
  };
}
