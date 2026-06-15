{ config, pkgs, lib, ... }:
let
  cfg = config.services.misskey-mk;
in {
  options.services.misskey-mk = {
    enable = lib.mkEnableOption "Misskey";
    name = lib.mkOption { type = lib.types.str; };
    url = lib.mkOption { type = lib.types.str; };
    imageTag = lib.mkOption { type = lib.types.str; };
    sharedBuffers = lib.mkOption { type = lib.types.str; default = "2GB"; };
    extraConfig = lib.mkOption { type = lib.types.lines; default = ""; };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.arion.projects."${cfg.name}".settings = {
      project.name = cfg.name;

      services.web.service = {
        image = "misskey/misskey:${cfg.imageTag}";
        restart = "always";
        volumes = [
          "/etc/${cfg.name}/default.yml:/misskey/.config/default.yml:ro"
        ];
        network_mode = "host";
      };
    };

    environment.etc."${cfg.name}/default.yml".text = ''
      url: ${cfg.url}
      port: 3000

      db:
        host: 127.0.0.1
        port: 5432
        db: ${cfg.name}
        user: postgres
        extra:
          statement_timeout: 0

      redis:
        host: 127.0.0.1
        port: 6379

      ${cfg.extraConfig}

      proxyBypassHosts:
        - api.deepl.com
        - api-free.deepl.com
        - www.recaptcha.net
        - hcaptcha.com
        - challenges.cloudflare.com

      id: 'aid'

      signToActivityPubGet: true
    '';

    services.redis.servers."${cfg.name}" = {
      enable = true;
      port = 6379;
      bind = "127.0.0.1";
    };

    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_18;
      ensureDatabases = [ cfg.name ];
      authentication = pkgs.lib.mkForce ''
        local all all trust
        host  all all 127.0.0.1/32 trust
        host  all all ::1/128 trust
      '';
      settings.shared_buffers = cfg.sharedBuffers;
    };
  };
}
