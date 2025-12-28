{ config, pkgs, ... }:

{
  imports = [
    ../../../programs/starship
    ../../../programs/fish
    ../../../programs/git
  ];

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    ungoogled-chromium
    neofetch
    nnn # terminal file manager
    openssl
    # archives
    zip
    xz
    unzip
    p7zip
    micro
    nixfmt-rfc-style
    # utils
    eza # A modern replacement for ‘ls’

    # networking tools
    dnsutils # `dig` + `nslookup`
    # ldns # replacement of `dig`, it provide the command `drill`
    nmap # A utility for network discovery and security auditing
    ipcalc # it is a calculator for the IPv4/v6 addresses

    # misc
    file
    which
    tree

    # nix related
    #
    # it provides the command `nom` works just like `nix`
    # with more details log output
    nix-output-monitor

    lsof # list open files
    vesktop
  ];

  home.stateVersion = "24.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
