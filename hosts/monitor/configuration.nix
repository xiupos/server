{ pkgs, ... }: {
  imports = [];

  # Networking
  networking.hostName = "monitor";

  # System state version
  system.stateVersion = "25.11";
}
