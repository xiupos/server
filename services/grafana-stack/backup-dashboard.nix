{ pkgs, ... }:
let
  lokiDs = { type = "datasource"; uid = "loki"; };

  qSuccessCount = unitRegex: {
    datasource = lokiDs;
    expr = ''count_over_time({job="journal", instance="$instance", unit=~"${unitRegex}"} |= "Succeeded" [$__range])'';
    legendFormat = "successes";
  };
  qFailureCount = unitRegex: {
    datasource = lokiDs;
    expr = ''count_over_time({job="journal", instance="$instance", unit=~"${unitRegex}"} |= "Failed" [$__range])'';
    legendFormat = "failures";
  };
  qSuccessTs = unitRegex: label: {
    datasource = lokiDs;
    expr = ''count_over_time({job="journal", instance="$instance", unit=~"${unitRegex}"} |= "Succeeded" [$__interval])'';
    legendFormat = "${label} success";
  };
  qFailureTs = unitRegex: label: {
    datasource = lokiDs;
    expr = ''count_over_time({job="journal", instance="$instance", unit=~"${unitRegex}"} |= "Failed" [$__interval])'';
    legendFormat = "${label} failure";
  };

  statPanel = { id, title, gridPos, targets, thresholds }: {
    type = "stat";
    inherit id title gridPos targets;
    fieldConfig.defaults = {
      color.mode = "thresholds";
      inherit thresholds;
      mappings = [];
    };
    options = {
      reduceOptions = {
        calcs = [ "sum" ];
        fields = "";
        values = false;
      };
      orientation = "auto";
      textMode = "auto";
      colorMode = "background";
      graphMode = "none";
    };
  };

  timeseriesPanel = { id, title, gridPos, targets }: {
    type = "timeseries";
    inherit id title gridPos targets;
    fieldConfig.defaults = {
      custom = {
        drawStyle = "bars";
        lineWidth = 0;
        fillOpacity = 80;
        gradientMode = "none";
        spanNulls = false;
        barAlignment = 0;
      };
      color.mode = "palette-classic";
      mappings = [];
    };
    options = {
      tooltip.mode = "multi";
      legend.displayMode = "list";
      legend.placement = "bottom";
    };
  };

  thresholdsSuccess = {
    steps = [
      { color = "red";   value = null; }
      { color = "green"; value = 1; }
    ];
  };
  thresholdsFailure = {
    steps = [
      { color = "green"; value = null; }
      { color = "red";   value = 1; }
    ];
  };

  dashboardJson = {
    id = null;
    uid = "backup-misskey-mk";
    title = "Backup — misskey-mk";
    tags = [ "backup" ];
    timezone = "browser";
    schemaVersion = 41;
    refresh = "5m";
    time = { from = "now-7d"; to = "now"; };

    templating.list = [
      {
        name       = "instance";
        label      = "Instance";
        type       = "query";
        datasource = lokiDs;
        query      = ''label_values({job="journal",unit=~"backup-.+-db-r2\\.service"},instance)'';
        refresh    = 2;
        sort       = 1;
        includeAll = false;
        multi      = false;
        current    = {};
      }
    ];

    panels = [
      # ── Row: R2 ──────────────────────────────────────────────────────────── #
      {
        type = "row"; id = 1; title = "R2";
        gridPos = { x = 0; y = 0; w = 24; h = 1; };
        collapsed = false;
      }
      (statPanel {
        id = 2; title = "Successes (selected range)";
        gridPos = { x = 0; y = 1; w = 6; h = 4; };
        targets = [ (qSuccessCount "backup-.+-db-r2\\.service") ];
        thresholds = thresholdsSuccess;
      })
      (statPanel {
        id = 3; title = "Failures (selected range)";
        gridPos = { x = 6; y = 1; w = 6; h = 4; };
        targets = [ (qFailureCount "backup-.+-db-r2\\.service") ];
        thresholds = thresholdsFailure;
      })
      (timeseriesPanel {
        id = 4; title = "Hourly results — R2";
        gridPos = { x = 12; y = 1; w = 12; h = 8; };
        targets = [
          (qSuccessTs "backup-.+-db-r2\\.service" "R2")
          (qFailureTs "backup-.+-db-r2\\.service" "R2")
        ];
      })

      # ── Row: Google Drive ─────────────────────────────────────────────────── #
      {
        type = "row"; id = 5; title = "Google Drive";
        gridPos = { x = 0; y = 5; w = 24; h = 1; };
        collapsed = false;
      }
      (statPanel {
        id = 6; title = "Successes (selected range)";
        gridPos = { x = 0; y = 6; w = 6; h = 4; };
        targets = [ (qSuccessCount "backup-.+-db-gdrive\\.service") ];
        thresholds = thresholdsSuccess;
      })
      (statPanel {
        id = 7; title = "Failures (selected range)";
        gridPos = { x = 6; y = 6; w = 6; h = 4; };
        targets = [ (qFailureCount "backup-.+-db-gdrive\\.service") ];
        thresholds = thresholdsFailure;
      })
      (timeseriesPanel {
        id = 8; title = "Hourly results — Google Drive";
        gridPos = { x = 12; y = 6; w = 12; h = 8; };
        targets = [
          (qSuccessTs "backup-.+-db-gdrive\\.service" "GDrive")
          (qFailureTs "backup-.+-db-gdrive\\.service" "GDrive")
        ];
      })

      # ── Row: Logs ─────────────────────────────────────────────────────────── #
      {
        type = "row"; id = 9; title = "Logs";
        gridPos = { x = 0; y = 14; w = 24; h = 1; };
        collapsed = false;
      }
      {
        type = "logs"; id = 10; title = "Recent backup logs";
        gridPos = { x = 0; y = 15; w = 24; h = 10; };
        targets = [
          {
            datasource = lokiDs;
            expr = ''{job="journal", instance="$instance", unit=~"backup-.+-db-.+\\.service"}'';
            legendFormat = "";
          }
        ];
        options = {
          dedupStrategy    = "none";
          enableLogDetails = true;
          prettifyLogMessage = false;
          showCommonLabels = false;
          showLabels       = true;
          showTime         = true;
          sortOrder        = "Descending";
          wrapLogMessage   = false;
        };
      }
    ];
  };
in
{
  services.grafana.provision.dashboards.settings.providers = [
    {
      name   = "backup";
      orgId  = 1;
      folder = "Backup";
      type   = "file";
      disableDeletion = false;
      updateIntervalSeconds = 30;
      options.path = pkgs.writeTextDir "misskey-mk-backup.json"
        (builtins.toJSON dashboardJson);
    }
  ];
}
