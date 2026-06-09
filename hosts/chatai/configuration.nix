{ pkgs, ... }: {
  imports = [];

  # Networking
  networking.hostName = "chatai";

  # System state version
  system.stateVersion = "26.05";
}
