{ config, pkgs, ... }: {
  services.alloy.enable = true;

  environment.etc."alloy/base.alloy".text = ''
    // Endpoints
    prometheus.remote_write "monitor" {
      endpoint { url = "http://monitor:9090/api/v1/write" }
    }
    loki.write "monitor" {
      endpoint { url = "http://monitor:3100/loki/api/v1/push" }
    }

    // System metrics
    prometheus.exporter.unix "system" {}

    prometheus.relabel "system" {
      forward_to = [prometheus.remote_write.monitor.receiver]

      rule {
        target_label = "job"
        replacement  = "node"
      }
      rule {
        target_label = "instance"
        replacement  = "${config.networking.hostName}"
      }
    }

    prometheus.scrape "system" {
      targets         = prometheus.exporter.unix.system.targets
      forward_to      = [prometheus.relabel.system.receiver]
      scrape_interval = "60s"
    }

    // Systemd journal
    loki.source.journal "systemd" {
      forward_to    = [loki.write.monitor.receiver]
      relabel_rules = loki.relabel.journal.rules
      labels        = {
        job      = "journal",
        instance = "${config.networking.hostName}",
      }
    }

    loki.relabel "journal" {
      forward_to = []
      rule {
        source_labels = ["__journal__systemd_unit"]
        target_label  = "unit"
      }
      rule {
        source_labels = ["__journal_priority_keyword"]
        target_label  = "level"
      }
    }
  '';
}
