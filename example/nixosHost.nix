{
  config,
  pkgs,
  ...
}: {
  boot.loader.systemd-boot.enable = true;
  system.stateVersion = "24.11";
}
