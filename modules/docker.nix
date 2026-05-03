{ ... }: {
  # Docker
  virtualisation.docker = {
    enable = true;

    # Automatic pruning of unused images, containers, and volumes
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # Arion
  virtualisation.arion.backend = "docker";
}
