{ ... }: {
  imports = [
    ../services/postgres
    ../services/grafana-alloy
    ../services/grafana-alloy/postgres.nix
  ];

  # Networking
  networking.hostName = "pgdb";

  # System state version
  system.stateVersion = "26.05";
}
