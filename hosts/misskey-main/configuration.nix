{ pkgs, ... }: {
  imports = [];

  # Networking
  networking.hostName = "misskey-main";

  # System state version
  system.stateVersion = "26.05";

  # SOPS settings
  sops.defaultSopsFile = ../../secrets/misskey-main.yaml;
}
