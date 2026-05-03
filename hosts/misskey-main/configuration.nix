{ pkgs, ... }: {
  imports = [];

  # Networking
  networking.hostName = "misskey-main";

  # System state version
  system.stateVersion = "25.11";

  # SOPS settings
  sops.defaultSopsFile = ../../secrets/misskey-main.yaml;
}
