{ pkgs, ... }:
let
  promDs = { type = "prometheus"; uid = "prometheus"; };

  # Metrics are pushed by the Alloy add-on on Home Assistant
  # (homeassistant/addons/alloy) with job="homeassistant".
  q = expr: legendFormat: {
    datasource = promDs;
    inherit expr legendFormat;
  };

  temp     = ''hass_sensor_temperature_celsius{job="homeassistant", entity="sensor.hygrothermograph_temperature"}'';
  humidity = ''hass_sensor_humidity_percent{job="homeassistant", entity="sensor.hygrothermograph_humidity"}'';

  row = id: title: y: {
    type = "row"; inherit id title;
    gridPos = { x = 0; inherit y; w = 24; h = 1; };
    collapsed = false;
  };

  stat = { id, title, gridPos, targets, unit, decimals ? 1, thresholds ? null, mappings ? [] }: {
    type = "stat";
    inherit id title gridPos targets;
    fieldConfig.defaults = {
      inherit unit decimals mappings;
      color.mode = if thresholds == null then "fixed" else "thresholds";
      color.fixedColor = "text";
      thresholds = if thresholds == null
        then { mode = "absolute"; steps = [ { color = "text"; value = null; } ]; }
        else thresholds;
    };
    options = {
      reduceOptions = { calcs = [ "lastNotNull" ]; fields = ""; values = false; };
      colorMode = if thresholds == null then "none" else "background";
      graphMode = "none";
      textMode = "value";
      justifyMode = "center";
    };
  };

  line = { id, title, gridPos, targets, unit, min ? null, max ? null }: {
    type = "timeseries";
    inherit id title gridPos targets;
    fieldConfig.defaults = {
      inherit unit min max;
      custom = {
        drawStyle = "line";
        lineWidth = 2;
        fillOpacity = 0;
        showPoints = "never";
        spanNulls = true;
      };
      color.mode = "palette-classic";
    };
    options = {
      tooltip.mode = "multi";
      legend = { displayMode = "list"; placement = "bottom"; showLegend = false; };
    };
  };

  onOff = {
    type = "value";
    options = {
      "0" = { text = "Off"; color = "transparent"; index = 0; };
      "1" = { text = "On";  color = "orange";      index = 1; };
    };
  };

  dashboardJson = {
    id = null;
    uid = "homeassistant";
    title = "Home Assistant";
    tags = [ "home" ];
    timezone = "browser";
    schemaVersion = 41;
    refresh = "1m";
    time = { from = "now-24h"; to = "now"; };

    panels = [
      # ── Bedroom ──────────────────────────────────────────────────────────── #
      (row 1 "Bedroom" 0)
      (stat {
        id = 2; title = "Temperature";
        gridPos = { x = 0; y = 1; w = 4; h = 4; };
        targets = [ (q temp "Temperature") ];
        unit = "celsius";
      })
      (stat {
        id = 3; title = "Humidity";
        gridPos = { x = 0; y = 5; w = 4; h = 4; };
        targets = [ (q humidity "Humidity") ];
        unit = "percent"; decimals = 0;
      })
      (line {
        id = 4; title = "Temperature";
        gridPos = { x = 4; y = 1; w = 10; h = 8; };
        targets = [ (q temp "Temperature") ];
        unit = "celsius";
      })
      (line {
        id = 5; title = "Humidity";
        gridPos = { x = 14; y = 1; w = 10; h = 8; };
        targets = [ (q humidity "Humidity") ];
        unit = "percent"; min = 0; max = 100;
      })

      # ── Devices ──────────────────────────────────────────────────────────── #
      (row 6 "Devices" 9)
      {
        type = "state-timeline"; id = 7; title = "On / off";
        gridPos = { x = 0; y = 10; w = 24; h = 8; };
        targets = [
          (q ''hass_fan_state{job="homeassistant"}'' "{{friendly_name}}")
          (q ''hass_light_brightness_percent{job="homeassistant"} > bool 0'' "{{friendly_name}}")
        ];
        fieldConfig.defaults = {
          mappings = [ onOff ];
          color.mode = "thresholds";
          thresholds = { mode = "absolute"; steps = [
            { color = "transparent"; value = null; }
            { color = "orange"; value = 1; }
          ]; };
          custom = { fillOpacity = 80; lineWidth = 0; };
        };
        options = {
          showValue = "never";
          mergeValues = true;
          rowHeight = 0.8;
          alignValue = "left";
          legend.showLegend = false;
          tooltip.mode = "single";
        };
      }

      # ── Health ───────────────────────────────────────────────────────────── #
      (row 8 "Health" 18)
      {
        type = "bargauge"; id = 9; title = "Battery";
        gridPos = { x = 0; y = 19; w = 12; h = 8; };
        targets = [ (q ''hass_sensor_battery_percent{job="homeassistant"}'' "{{friendly_name}}") ];
        fieldConfig.defaults = {
          unit = "percent"; min = 0; max = 100; decimals = 0;
          color.mode = "thresholds";
          thresholds = { mode = "absolute"; steps = [
            { color = "red";    value = null; }
            { color = "orange"; value = 20; }
            { color = "green";  value = 40; }
          ]; };
        };
        options = {
          orientation = "horizontal";
          displayMode = "basic";
          valueMode = "text";
          showUnfilled = true;
          reduceOptions = { calcs = [ "lastNotNull" ]; fields = ""; values = false; };
        };
      }
      (stat {
        id = 10; title = "Metrics push";
        gridPos = { x = 12; y = 19; w = 4; h = 4; };
        targets = [ (q ''max(up{job="homeassistant"}) or vector(0)'' "up") ];
        unit = "none"; decimals = 0;
        thresholds = { mode = "absolute"; steps = [
          { color = "red";   value = null; }
          { color = "green"; value = 1; }
        ]; };
        mappings = [{
          type = "value";
          options = {
            "0" = { text = "Down"; index = 0; };
            "1" = { text = "OK";   index = 1; };
          };
        }];
      })
      (stat {
        id = 11; title = "Unavailable entities";
        gridPos = { x = 12; y = 23; w = 4; h = 4; };
        targets = [ (q ''count(hass_entity_available{job="homeassistant"} == 0) or vector(0)'' "unavailable") ];
        unit = "none"; decimals = 0;
      })
      {
        type = "table"; id = 12; title = "Unavailable now";
        gridPos = { x = 16; y = 19; w = 8; h = 8; };
        targets = [
          ((q ''hass_entity_available{job="homeassistant"} == 0'' "") // {
            format = "table"; instant = true;
          })
        ];
        transformations = [{
          id = "organize";
          options = {
            excludeByName = { Time = true; Value = true; __name__ = true; job = true; instance = true; domain = true; };
            renameByName = { entity = "Entity"; friendly_name = "Name"; };
          };
        }];
        options.showHeader = true;
      }
    ];
  };
in
{
  services.grafana.provision.dashboards.settings.providers = [
    {
      name   = "homeassistant";
      orgId  = 1;
      folder = "Home";
      type   = "file";
      disableDeletion = false;
      updateIntervalSeconds = 30;
      options.path = pkgs.writeTextDir "homeassistant.json"
        (builtins.toJSON dashboardJson);
    }
  ];
}
