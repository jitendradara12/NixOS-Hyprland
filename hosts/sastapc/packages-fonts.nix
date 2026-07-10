{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [ ];

  programs = {
    steam = {
      enable = false;
      gamescopeSession.enable = false;
    };
  };
}
