{ ... }: {
  # Rsyslogd
  services.rsyslogd = {
    enable = true;
    extraConfig = ''
      module(load="imudp")
      input(type="imudp" port="514")

      template(name="rfc5424" type="string"
        string="<%PRI%>1 %TIMESTAMP:::date-rfc3339% %HOSTNAME% %APP-NAME% %PROCID% %MSGID% - %MSG%\n"
      )

      *.* action(
        type="omfwd"
        target="127.0.0.1"
        port="5514"
        protocol="udp"
        template="rfc5424"
      )
    '';
  };

  networking.firewall.allowedUDPPorts = [ 514 ];

  environment.etc."alloy/rsyslog.alloy".text = ''
    loki.source.syslog "router" {
      listener {
        address  = "0.0.0.0:5514"
        protocol = "udp"
      }
      forward_to    = [loki.write.monitor.receiver]
      relabel_rules = loki.relabel.syslog_router.rules
    }
    loki.relabel "syslog_router" {
      forward_to = []
      rule {
        source_labels = ["__syslog_message_hostname"]
        target_label  = "host"
      }
      rule {
        source_labels = ["__syslog_message_facility"]
        target_label  = "facility"
      }
      rule {
        source_labels = ["__syslog_message_severity"]
        target_label  = "level"
      }
      rule {
        replacement  = "syslog"
        target_label = "job"
      }
    }
  '';
}
