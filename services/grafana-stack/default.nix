{ config, ... }: {
  # Grafana
  services.grafana = {
    enable = true;

    settings = {
      log.level = "warn";

      users.allow_sign_up = false;

      server = {
        http_port = 3000;
        # root_url = "https://monitor.tail7b2934.ts.net/";
      };

      security = {
        admin_user = "admin";
        admin_password = "admin";
      };
    };

    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://localhost:9090";
          isDefault = true;
          editable = false;
        }
        {
          name = "Loki";
          type = "loki";
          url = "http://localhost:3100";
          editable = false;
        }
      ];
    };
  };

  # Prometheus
  services.prometheus = {
    enable = true;
    port = 9090;

    retentionTime = "30d";

    extraFlags = [
      "--web.enable-remote-write-receiver"
    ];

    globalConfig.scrape_interval = "15s";

    scrapeConfigs = [
      {
        job_name = "prometheus";
        static_configs = [
          { targets = [ "localhost:9090" ]; }
        ];
      }
    ];
  };

  # Loki
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server.http_listen_port = 3100;

      ingester = {
        lifecycler = {
          address = "127.0.0.1";
          ring = {
            kvstore.store = "inmemory";
            replication_factor = 1;
          };
        };
        chunk_idle_period = "5m";
        chunk_retain_period = "30s";
      };

      schema_config.configs = [
        {
          from = "2025-01-01";
          store = "tsdb";
          object_store = "filesystem";
          schema = "v13";
          index = {
            prefix = "index_";
            period = "24h";
          };
        }
      ];

      storage_config = {
        tsdb_shipper = {
          active_index_directory = "/var/lib/loki/tsdb-index";
          cache_location = "/var/lib/loki/tsdb-cache";
        };
        filesystem.directory = "/var/lib/loki/chunks";
      };

      compactor = {
        working_directory = "/var/lib/loki/compactor";
        delete_request_store = "filesystem";
      };

      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
      };
    };
  };
}
