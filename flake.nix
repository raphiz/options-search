{
  description = "Simple nix documentation generator";

  outputs = {...}: {
    lib = {
      optionsDocHtml = import ./doc.nix;
    };
  };
}
