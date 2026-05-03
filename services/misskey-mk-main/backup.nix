{ config, pkgs, ... }:
let
  misskeyName = "misskey-mk-main";
in {
  environment.systemPackages = with pkgs; [ rclone ];

  sops.secrets."rclone/config" = {
    sopsFile = ../../secrets/rclone-backup.yaml;
    path = "/etc/rclone.conf";
    owner = "postgres";
    mode = "0400";
  };

  # Backup Misskey PostgreSQL to R2
  systemd.services."backup-${misskeyName}-db-r2" = {
    description = "Backup ${misskeyName} PostgreSQL to R2";
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      RuntimeDirectory = "backup-${misskeyName}-db-r2";
    };
    script = ''
      set -euo pipefail

      cp ${config.sops.secrets."rclone/config".path} /run/backup-${misskeyName}-db-r2/rclone.conf
      chmod 600 /run/backup-${misskeyName}-db-r2/rclone.conf

      TMPFILE=$(mktemp /run/backup-${misskeyName}-db-r2/misskey-pgdump-XXXXXX.sql.gz)
      trap 'rm -f "$TMPFILE"' EXIT

      ${pkgs.postgresql_18}/bin/pg_dump \
        --no-owner \
        --no-acl \
        --clean \
        --if-exists \
        ${misskeyName} \
        | ${pkgs.gzip}/bin/gzip > "$TMPFILE"

      ${pkgs.rclone}/bin/rclone \
        --config /run/backup-${misskeyName}-db-r2/rclone.conf \
        copyto "$TMPFILE" \
        r2:backup/${misskeyName}/db/dump.sql.gz
    '';
  };
  systemd.timers."backup-${misskeyName}-db-r2" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:00:00";
      Persistent = true;
    };
  };

  # Backup Misskey PostgreSQL to Google Drive
  systemd.services."backup-${misskeyName}-db-gdrive" = {
    description = "Backup ${misskeyName} PostgreSQL to Google Drive";
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      RuntimeDirectory = "backup-${misskeyName}-db-gdrive";
    };
    script = ''
      set -euo pipefail

      cp ${config.sops.secrets."rclone/config".path} /run/backup-${misskeyName}-db-gdrive/rclone.conf
      chmod 600 /run/backup-${misskeyName}-db-gdrive/rclone.conf

      TMPFILE=$(mktemp /run/backup-${misskeyName}-db-gdrive/misskey-pgdump-XXXXXX.sql.gz)
      trap 'rm -f "$TMPFILE"' EXIT

      ${pkgs.postgresql_18}/bin/pg_dump \
        --no-owner \
        --no-acl \
        --clean \
        --if-exists \
        ${misskeyName} \
        | ${pkgs.gzip}/bin/gzip > "$TMPFILE"

      ${pkgs.rclone}/bin/rclone \
        --config /run/backup-${misskeyName}-db-gdrive/rclone.conf \
        copyto "$TMPFILE" \
        gdrive:Backup/Servers/${misskeyName}/db/dump.sql.gz
    '';
  };
  systemd.timers."backup-${misskeyName}-db-gdrive" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:30:00";
      Persistent = true;
    };
  };
}
