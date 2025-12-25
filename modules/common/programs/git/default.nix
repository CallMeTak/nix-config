{ config, pkgs, ... }:
{
  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "Tak";
    userEmail = "tak@callmetak.com";
  };

}
