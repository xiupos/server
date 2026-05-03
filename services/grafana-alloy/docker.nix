{ config, ... }: {
  environment.etc."alloy/docker.alloy".text = ''
    discovery.docker "containers" {
      host = "unix:///var/run/docker.sock"
    }
    discovery.relabel "docker" {
      targets = discovery.docker.containers.targets
      rule {
        source_labels = ["__meta_docker_container_name"]
        regex         = "/(.*)"
        target_label  = "container"
      }
      rule {
        source_labels = ["__meta_docker_container_label_com_docker_compose_service"]
        target_label  = "service"
      }
      rule {
        replacement  = "${config.networking.hostName}"
        target_label = "job"
      }
    }
    loki.source.docker "containers" {
      host          = "unix:///var/run/docker.sock"
      targets       = discovery.relabel.docker.output
      forward_to    = [loki.write.monitor.receiver]
      relabel_rules = discovery.relabel.docker.rules
    }
  '';

  systemd.services.alloy.serviceConfig.SupplementaryGroups = [ "docker" ];
}
