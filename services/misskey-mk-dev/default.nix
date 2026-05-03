{ pkgs, ... }: {
  # Misskey
  virtualisation.arion.projects."misskey-mk-dev".settings = {
    project.name = "misskey-mk-dev";

    services.web.service = {
      image = "misskey/misskey:latest";
      restart = "always";
      volumes = [
        "/etc/misskey-mk-dev/default.yml:/misskey/.config/default.yml:ro"
      ];
      network_mode = "host";
    };
  };

  environment.etc."misskey-mk-dev/default.yml".text = ''
    url: https://mk-dev.xiupos.net/
    port: 3000

    db:
      host: 127.0.0.1
      port: 5432
      db: misskey-mk-dev
      user: postgres
      extra:
        statement_timeout: 0

    redis:
      host: 127.0.0.1
      port: 6379

    # Dummy proxy for testing
    proxy: http://127.0.0.1:3128

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
  services.redis.servers."misskey-mk-dev" = {
    enable = true;
    port = 6379;
    bind = "127.0.0.1";
  };

  # PostgreSQL
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;

    # Database and user setup for Misskey
    ensureDatabases = [ "misskey-mk-dev" ];

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
