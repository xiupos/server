{ claude-code, ... }: {
  imports = [
    ../services/claude-code
    ../services/grafana-alloy
  ];

  # Networking
  networking.hostName = "agent";

  # System state version
  system.stateVersion = "26.05";
}
