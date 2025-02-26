{
  description = "Simple nix documentation generator";

  outputs = {...}: {
    lib = {
      optionsDocHtml = import ./html;
      mkOptionsSearch = import ./cli;
    };
  };
}
