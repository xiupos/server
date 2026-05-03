{ ... }: {
  # LXC
  boot.isContainer = true;
  nix.settings.sandbox = false;

  # SSH
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Disable debugfs mount
  systemd.mounts = [{
    where = "/sys/kernel/debug";
    enable = false;
  }];
}
