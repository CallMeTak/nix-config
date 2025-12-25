{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./audio
    ./bootloader
    ./desktop
    ./network
  ];
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  time.timeZone = "America/New_York";
  environment.systemPackages = with pkgs; [
    fish
    tree
    eza
    pciutils
    usbutils
    which
    dnsutils
    mesa
    vscode

  ];
  services.tailscale.enable = true;
  # Avoids emergency shell login issue. https://nixos.wiki/wiki/Fish
  programs.bash = {
    interactiveShellInit = ''
      if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
      then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
  programs.firefox.enable = lib.mkDefault true;
  system.stateVersion = "24.11";
}
