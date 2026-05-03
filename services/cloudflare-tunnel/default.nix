{ config, pkgs, ... }: {
  sops.secrets."cloudflared/tunnel-token" = {};

  systemd.services."cloudflared" = {
    description = "Cloudflare Tunnel";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      EnvironmentFile = config.sops.secrets."cloudflared/tunnel-token".path;
      ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --no-autoupdate run --token $TUNNEL_TOKEN";
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };
}
