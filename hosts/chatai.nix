{ arion, ... }: {
  imports = [
    arion.nixosModules.arion
    ../modules/docker.nix
    ../services/open-webui
    ../services/grafana-alloy
    ../services/grafana-alloy/docker.nix
  ];

  # Networking
  networking.hostName = "chatai";

  # System state version
  system.stateVersion = "26.05";
}
