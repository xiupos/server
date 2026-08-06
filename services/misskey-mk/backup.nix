{ config, pkgs, lib, ... }:
let
  cfg = config.services.misskey-mk-backup;
  mkName = config.services.misskey-mk.name;
in {
  options.services.misskey-mk-backup = {
    enable = lib.mkEnableOption "Misskey backup";
    sopsFile = lib.mkOption { type = lib.types.path; };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ rclone ];

    sops.secrets."rclone/config" = {
      sopsFile = cfg.sopsFile;
      path = "/etc/rclone.conf";
      owner = "postgres";
      mode = "0400";
    };

    systemd.services."backup-${mkName}-db-r2" = {
      description = "Backup ${mkName} PostgreSQL to R2";
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        MemoryMax = "2048M";
        Nice = 19;
        IOSchedulingClass = "idle";
      };
      script = ''
        set -euo pipefail
        trap 'echo "backup: Failed" >&2' ERR

        ${pkgs.postgresql_18}/bin/pg_dump \
          --no-owner \
          --no-acl \
          --clean \
          --if-exists \
          ${mkName} \
          | ${pkgs.gzip}/bin/gzip \
          | ${pkgs.rclone}/bin/rclone \
              --config ${config.sops.secrets."rclone/config".path} \
              rcat \
              r2:backup/${mkName}/db/dump.sql.gz

        echo "backup: Succeeded"
      '';
    };
    systemd.timers."backup-${mkName}-db-r2" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* *:00:00";
        Persistent = true;
      };
    };

    systemd.services."backup-${mkName}-db-gdrive" = {
      description = "Backup ${mkName} PostgreSQL to Google Drive";
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        MemoryMax = "2048M";
        Nice = 19;
        IOSchedulingClass = "idle";
      };
      script = ''
        set -euo pipefail
        trap 'echo "backup: Failed" >&2' ERR

        ${pkgs.postgresql_18}/bin/pg_dump \
          --no-owner \
          --no-acl \
          --clean \
          --if-exists \
          ${mkName} \
          | ${pkgs.gzip}/bin/gzip \
          | ${pkgs.rclone}/bin/rclone \
              --config ${config.sops.secrets."rclone/config".path} \
              rcat \
              gdrive:Backup/Servers/${mkName}/db/dump.sql.gz

        echo "backup: Succeeded"
      '';
    };
    systemd.timers."backup-${mkName}-db-gdrive" = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*-*-* *:30:00";
        Persistent = true;
      };
    };
  };
}
