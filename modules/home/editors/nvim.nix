{ pkgs, lib, ... }:
{
  # Install neovim and required dependencies
  home.packages = with pkgs; [
    neovim
    ripgrep
    fd
    bat
    wl-clipboard
    lazygit
    nixd
    hyprls
    typescript-language-server
    typescript
    vscode-langservers-extracted
    pyright
    lua-language-server
    zls
    marksman
    clang-tools
    prettierd
    stylua
    shfmt
    nixpkgs-fmt
    figlet
    toilet
    # Language servers and tools
    nodejs
    python3
    # For treesitter
    tree-sitter
  ];

  # Link the user's actual nvim config from the repository
  # Assumes the config lives in the repo at .config/nvim relative to the flake root
  # xdg.configFile."nvim" = {
  #   source = ../.. + "/.config/nvim";
  #   recursive = true;
  # };

  # Ensure neovim is the default editor
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
