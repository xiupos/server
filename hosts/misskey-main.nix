{ arion, ... }: {
  imports = [
    arion.nixosModules.arion
    ../modules/docker.nix
    ../services/misskey-mk
    ../services/misskey-mk/backup.nix
    ../services/cloudflare-tunnel
    ../services/grafana-alloy
    ../services/grafana-alloy/docker.nix
    ../services/grafana-alloy/postgres.nix
  ];

  # Networking
  networking.hostName = "misskey-main";

  # Secrets
  sops.defaultSopsFile = ../secrets/misskey-main.yaml;

  # Misskey
  services.misskey-mk = {
    enable = true;
    name = "misskey-mk-main";
    url = "https://mk.xiupos.net/";
    imageTag = "2026.6.0";
  };

  # Misskey backup
  services.misskey-mk-backup = {
    enable = true;
    sopsFile = ../secrets/rclone-backup.yaml;
  };

  # System state version
  system.stateVersion = "26.05";
}
