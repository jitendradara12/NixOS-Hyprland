{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    google-chrome
  ];

  programs = {
    steam = {
      enable = false;
      gamescopeSession.enable = false;
    };
  };
}
