{ config, ... }: {
  environment.etc."alloy/postgres.alloy".text = ''
    prometheus.exporter.postgres "main" {
      data_source_names = ["postgresql:///postgres?host=/run/postgresql&user=postgres"]
    }

    prometheus.relabel "postgres" {
      forward_to = [prometheus.remote_write.monitor.receiver]

      rule {
        target_label = "job"
        replacement  = "postgres"
      }
      rule {
        target_label = "instance"
        replacement  = "${config.networking.hostName}"
      }
    }

    prometheus.scrape "postgres" {
      targets         = prometheus.exporter.postgres.main.targets
      forward_to      = [prometheus.relabel.postgres.receiver]
      scrape_interval = "60s"
    }
  '';

  users.groups.postgres.members = [ "alloy" ];
}
