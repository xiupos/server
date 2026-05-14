{ pkgs, ... }:
let
  misskeyName = "misskey-mk-main";
  misskeyImage = "misskey/misskey:2026.5.1";
  url = "https://mk.xiupos.net/";
in {
  system.activationScripts."pull-${misskeyName}".text = ''
    ${pkgs.docker}/bin/docker pull ${misskeyImage}
  '';

  # Misskey
  virtualisation.arion.projects."${misskeyName}".settings = {
    project.name = "${misskeyName}";

    services.web.service = {
      image = misskeyImage;
      restart = "always";
      volumes = [
        "/etc/${misskeyName}/default.yml:/misskey/.config/default.yml:ro"
      ];
      network_mode = "host";
    };
  };

  environment.etc."${misskeyName}/default.yml".text = ''
    url: ${url}
    port: 3000

    db:
      host: 127.0.0.1
      port: 5432
      db: ${misskeyName}
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
  services.redis.servers."${misskeyName}" = {
    enable = true;
    port = 6379;
    bind = "127.0.0.1";
  };

  # PostgreSQL
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_18;

    # Database and user setup for Misskey
    ensureDatabases = [ misskeyName ];

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
