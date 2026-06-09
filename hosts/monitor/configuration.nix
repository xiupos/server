{ pkgs, ... }: {
  imports = [];

  # Networking
  networking.hostName = "monitor";

  networking = {
    interfaces.eth0.ipv4.addresses = [{
      address = "10.0.0.17";
      prefixLength = 24;
    }];
    defaultGateway = "10.0.0.1";
  };

  # System state version
  system.stateVersion = "26.05";
}
