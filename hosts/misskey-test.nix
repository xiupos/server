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
  networking.hostName = "misskey-test";

  # Secrets
  sops.defaultSopsFile = ../secrets/misskey-test.yaml;

  # Misskey
  services.misskey-mk = {
    enable = true;
    name = "misskey-mk-dev";
    url = "https://mk-dev.xiupos.net/";
    imageTag = "2026.5.4";
    extraConfig = "proxy: http://127.0.0.1:3128";
  };

  # Misskey backup
  services.misskey-mk-backup = {
    enable = true;
    sopsFile = ../secrets/rclone-backup.yaml;
  };

  # System state version
  system.stateVersion = "26.05";
}
