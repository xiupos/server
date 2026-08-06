{ pkgs, ... }: {
  # Networking
  services.tailscale.enable = true;
  services.tailscale.openFirewall = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  # To prevent SSH disconnection during deployment
  systemd.services.tailscaled.restartIfChanged = false;
  systemd.services.dhcpcd.restartIfChanged = false;

  # Timezone
  time.timeZone = "Asia/Tokyo";

  # Localisation
  i18n.defaultLocale = "en_GB.UTF-8";

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
    htop
    sops
    age
  ];

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # SOPS-Nix settings
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";
}
