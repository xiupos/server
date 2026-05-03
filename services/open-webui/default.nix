{ ... }: {
  virtualisation.arion.projects."open-webui" = {
    settings = {
      project.name = "open-webui";

      services.open-webui.service = {
        image = "ghcr.io/open-webui/open-webui:main";
        restart = "always";
        ports = [
          "8080:8080"
        ];
        volumes = [
          "open-webui-data:/app/backend/data"
        ];
        extra_hosts = [
          "host.docker.internal:host-gateway"
        ];
      };

      docker-compose.volumes = {
        "open-webui-data" = {};
      };
    };
  };
}
