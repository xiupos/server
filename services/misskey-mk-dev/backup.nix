{ config, pkgs, ... }: {
  environment.systemPackages = with pkgs; [ rclone ];

  sops.secrets."rclone/config" = {
    sopsFile = ../../secrets/rclone-backup.yaml;
    path = "/etc/rclone.conf";
    owner = "postgres";
    mode = "0400";
  };

  # Backup Misskey PostgreSQL to R2
  systemd.services."backup-misskey-mk-dev-db-r2" = {
    description = "Backup misskey-mk-dev PostgreSQL to R2";
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      RuntimeDirectory = "backup-misskey-mk-dev-db-r2";
    };
    script = ''
      set -euo pipefail

      cp ${config.sops.secrets."rclone/config".path} /run/backup-misskey-mk-dev-db-r2/rclone.conf
      chmod 600 /run/backup-misskey-mk-dev-db-r2/rclone.conf

      TMPFILE=$(mktemp /run/backup-misskey-mk-dev-db-r2/misskey-pgdump-XXXXXX.sql.gz)
      trap 'rm -f "$TMPFILE"' EXIT

      ${pkgs.postgresql_18}/bin/pg_dump \
        --no-owner \
        --no-acl \
        --clean \
        --if-exists \
        misskey-mk-dev \
        | ${pkgs.gzip}/bin/gzip > "$TMPFILE"

      ${pkgs.rclone}/bin/rclone \
        --config /run/backup-misskey-mk-dev-db-r2/rclone.conf \
        copyto "$TMPFILE" \
        r2:backup/misskey-mk-dev/db/dump.sql.gz
    '';
  };
  systemd.timers."backup-misskey-mk-dev-db-r2" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:00:00";
      Persistent = true;
    };
  };

  # Backup Misskey PostgreSQL to Google Drive
  systemd.services."backup-misskey-mk-dev-db-gdrive" = {
    description = "Backup misskey-mk-dev PostgreSQL to Google Drive";
    requires = [ "postgresql.service" ];
    after = [ "postgresql.service" ];
    serviceConfig = {
      Type = "oneshot";
      User = "postgres";
      RuntimeDirectory = "backup-misskey-mk-dev-db-gdrive";
    };
    script = ''
      set -euo pipefail

      cp ${config.sops.secrets."rclone/config".path} /run/backup-misskey-mk-dev-db-gdrive/rclone.conf
      chmod 600 /run/backup-misskey-mk-dev-db-gdrive/rclone.conf

      TMPFILE=$(mktemp /run/backup-misskey-mk-dev-db-gdrive/misskey-pgdump-XXXXXX.sql.gz)
      trap 'rm -f "$TMPFILE"' EXIT

      ${pkgs.postgresql_18}/bin/pg_dump \
        --no-owner \
        --no-acl \
        --clean \
        --if-exists \
        misskey-mk-dev \
        | ${pkgs.gzip}/bin/gzip > "$TMPFILE"

      ${pkgs.rclone}/bin/rclone \
        --config /run/backup-misskey-mk-dev-db-gdrive/rclone.conf \
        copyto "$TMPFILE" \
        gdrive:Backup/Servers/misskey-mk-dev/db/dump.sql.gz
    '';
  };
  systemd.timers."backup-misskey-mk-dev-db-gdrive" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* *:30:00";
      Persistent = true;
    };
  };
}
