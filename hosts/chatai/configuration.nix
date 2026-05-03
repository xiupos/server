{ pkgs, ... }: {
  imports = [];

  # Networking
  networking.hostName = "chatai";

  # System state version
  system.stateVersion = "25.11";
}
