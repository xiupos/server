{ pkgs, ... }: {
  imports = [];

  # Networking
  networking.hostName = "misskey-test";

  # System state version
  system.stateVersion = "25.11";

  # SOPS settings
  sops.defaultSopsFile = ../../secrets/misskey-test.yaml;
}
