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

  networking.hostName = "misskey-main";
  system.stateVersion = "26.05";
  sops.defaultSopsFile = ../secrets/misskey-main.yaml;

  services.misskey-mk = {
    enable = true;
    name = "misskey-mk-main";
    url = "https://mk.xiupos.net/";
    imageTag = "2026.5.4";
  };

  services.misskey-mk-backup = {
    enable = true;
    sopsFile = ../secrets/rclone-backup.yaml;
  };
}
