{ pkgs, ... }: {
  # Misskey
  virtualisation.arion.projects."misskey-mk-main".settings = {
    project.name = "misskey-mk-main";

    services.web.service = {
      image = "misskey/misskey:2026.5.0";
      restart = "always";
      volumes = [
        "/etc/misskey-mk-main/default.yml:/misskey/.config/default.yml:ro"
      ];
      network_mode = "host";
    };
  };

  environment.etc."misskey-mk-main/default.yml".text = ''
    url: https://mk.xiupos.net/
    port: 3000

    db:
      host: 127.0.0.1
      port: 5432
      db: misskey-mk-main
      user: postgres
      extra:
        statement_timeout: 0

    redis:
      host: 127.0.0.1
      port: 6379

    proxyBypassHosts:
      - api.deepl.com
      - api-free.deepl.com
      - www.recaptcha.net
      - hcaptcha.com
      - challenges.cloudflare.com

    id: 'aid'

    signToActivityPubGet: true
  '';

  # Redis
  services.redis.servers."misskey-mk-main" = {
    enable = true;
    port = 6379;
    bind = "127.0.0.1";
  };

  # PostgreSQL
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;

    # Database and user setup for Misskey
    ensureDatabases = [ "misskey-mk-main" ];

    # Allow local connections without password
    authentication = pkgs.lib.mkForce ''
      local all all trust
      host  all all 127.0.0.1/32 trust
      host  all all ::1/128 trust
    '';

    # Performance tuning for Misskey
    # (value suggested: 25% of total RAM)
    settings.shared_buffers = "2GB";
  };
}
