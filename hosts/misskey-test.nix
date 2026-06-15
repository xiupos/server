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

  networking.hostName = "misskey-test";
  system.stateVersion = "26.05";
  sops.defaultSopsFile = ../secrets/misskey-test.yaml;

  services.misskey-mk = {
    enable = true;
    name = "misskey-mk-dev";
    url = "https://mk-dev.xiupos.net/";
    imageTag = "2026.5.4";
    extraConfig = "proxy: http://127.0.0.1:3128";
  };

  services.misskey-mk-backup = {
    enable = true;
    sopsFile = ../secrets/rclone-backup.yaml;
  };
}
