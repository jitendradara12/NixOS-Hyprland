{
  config,
  pkgs,
  lib,
  ...
}:

{
  # 1. Custom User Packages (excluding those already installed globally by KoolDots)
  home.packages = [
    # --- Development & Languages ---
    pkgs.gdb
    pkgs.clang-tools
    pkgs.gh
    pkgs.hugo
    pkgs.pnpm
    pkgs.protobuf
    pkgs.pandoc # Markdown document converter (pandoc-cli)
    pkgs.ruby
    pkgs.rustc
    pkgs.git-filter-repo
    pkgs.mercurial
    (pkgs.python3.withPackages (
      ps: with ps; [
        django
        pip
        black # Python code formatter
      ]
    ))

    # --- Extra Hyprland / Wayland Ecosystem ---
    pkgs.hyprsunset # Blue light filter at compositor level
    pkgs.pyprland # Plugins/extensions for Hyprland layouts

    # --- Applications & Media ---
    pkgs.gimp # Image editor
    pkgs.obs-studio # Screen recorder/streamer
    pkgs.qbittorrent # Torrent client

    # --- System & Custom Utilities ---
    pkgs.nautilus # GNOME file manager
    # pkgs.pokeget                # Fast Rust-based random Pokemon sprite printer
    pkgs.cowsay
    pkgs.tree
    pkgs.zsh-autosuggestions
    pkgs.zsh-syntax-highlighting
  ];

  # 2. Zsh Shell configuration (retaining your prompt and aliases)
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };

    shellAliases = {
      # ls = lib.mk"eza -a --icons";
      # ll = lib.mkForce"eza -al --icons";
      # lt = "eza -a --tree --level=1 --icons";
      ff = "nvim $(fzf --preview=\"bat --color=always {}\")";
      y = "yazi";
    };

    initExtra = ''
      # Print a random pokemon sprite on shell startup (pokeget)
      if command -v pokeget &> /dev/null; then
        pokeget random --quiet
      fi

      # Custom 'apple' theme prompt configuration
      function toon {
        echo -n ""
      }

      autoload -Uz vcs_info
      zstyle ':vcs_info:*' check-for-changes true
      zstyle ':vcs_info:*' unstagedstr '%F{red}*'   # display this when there are unstaged changes
      zstyle ':vcs_info:*' stagedstr '%F{yellow}+'  # display this when there are staged changes
      zstyle ':vcs_info:*' actionformats '%F{5}[%F{2}%b%F{3}|%F{1}%a%c%u%F{5}]%f '
      zstyle ':vcs_info:*' formats '%F{5}[%F{2}%b%c%u%F{5}]%f '
      zstyle ':vcs_info:svn:*' branchformat '%b'
      zstyle ':vcs_info:svn:*' actionformats '%F{5}[%F{2}%b%F{1}:%F{3}%i%F{3}|%F{1}%a%c%u%F{5}]%f '
      zstyle ':vcs_info:svn:*' formats '%F{5}[%F{2}%b%F{1}:%F{3}%i%c%u%F{5}]%f '
      zstyle ':vcs_info:*' enable git cvs svn

      theme_precmd () {
        vcs_info
      }

      setopt prompt_subst
      PROMPT='%{$fg[magenta]%}$(toon)%{$reset_color%} %~/ %{$reset_color%}''${vcs_info_msg_0_}%{$reset_color%}'

      autoload -U add-zsh-hook
      add-zsh-hook precmd theme_precmd

      # Source custom zshrc from Hyprland-Dots
      if [ -f /home/sastauser/Hyprland-Dots/config/zshrc ]; then
        source /home/sastauser/Hyprland-Dots/config/zshrc
      fi
    '';
  };

  # 3. Yazi file manager configuration
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      manager = {
        show_hidden = true;
        sort_by = "mtime";
      };
    };
  };

  # 4. Session Variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home.stateVersion = lib.mkForce "26.05";
}
