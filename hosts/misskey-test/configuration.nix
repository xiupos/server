{ pkgs, ... }: {
  imports = [];

  # Networking
  networking.hostName = "misskey-test";

  # System state version
  system.stateVersion = "26.05";

  # SOPS settings
  sops.defaultSopsFile = ../../secrets/misskey-test.yaml;
}
