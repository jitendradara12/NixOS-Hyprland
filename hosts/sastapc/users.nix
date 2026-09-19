{ pkgs, username, ... }:

{
  users = {
    mutableUsers = true;
    users."${username}" = {
      isNormalUser = true;
      description = "Nix User";
      extraGroups = [
        "networkmanager"
        "wheel"
        "video"
        "audio"
        "postgres"
      ];
      shell = pkgs.zsh;
    };
    users.root.hashedPassword = "!";
  };

  # Make sure zsh is registered as a system shell
  environment.shells = with pkgs; [ zsh ];

  # Enable vi editing mode by default for interactive shells
  environment.interactiveShellInit = ''
    set -o vi
  '';
}
