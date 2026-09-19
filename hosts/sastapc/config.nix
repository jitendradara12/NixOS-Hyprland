# 💫 https://github.com/LinuxBeginnings 💫 #
# Main default config for sastapc
{
  pkgs,
  lib,
  host,
  username,
  options,
  ...
}: let
  inherit (import ./variables.nix) keyboardLayout;
in {
  imports = [
    ./hardware.nix
    ./users.nix
    ./packages-fonts.nix
    ../../modules/amd-drivers.nix
    ../../modules/nvidia-drivers.nix
    ../../modules/nvidia-prime-drivers.nix
    ../../modules/intel-drivers.nix
    ../../modules/vm-guest-services.nix
    ../../modules/local-hardware-clock.nix
  ];

  # BOOT Loader Settings (GRUB EFI mode)
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
      "systemd.mask=dev-tpmrm0.device" # mask that stupid 1.5 mins systemd bug
      "nowatchdog"
      "modprobe.blacklist=iTCO_wdt" # watchdog for Intel
    ];

    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [];
    };

    # Disable systemd-boot
    loader.systemd-boot.enable = false;

    # Enable GRUB in EFI mode
    loader.grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true; # Detect Windows & Fedora
      configurationName = "${host}";
      extraEntries = ''
        menuentry "Fedora Linux (Btrfs subvol=root)" --class fedora --class gnu-linux --class gnu --class os {
          insmod part_gpt
          insmod btrfs
          search --no-floppy --fs-uuid --set=root a40abff3-854e-46d5-9b8c-19a81af460db
          linux /vmlinuz-7.1.3-200.fc44.x86_64 root=UUID=53bfa245-93cc-4980-b479-c59dda505bbe rootflags=subvol=root ro quiet
          initrd /initramfs-7.1.3-200.fc44.x86_64.img
        }
      '';
    };

    loader.efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };

    loader.timeout = 5;

    # Make /tmp a tmpfs
    tmp = {
      useTmpfs = false;
      tmpfsSize = "30%";
    };

    # Appimage Support
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };

    plymouth.enable = true;
  };

  # Driver options (Enable Intel for Intel Iris Xe integrated graphics)
  drivers = {
    amdgpu.enable = false;
    intel.enable = true;
    nvidia.enable = false;
    nvidia-prime.enable = false;
  };
  vm.guest-services.enable = false;
  local.hardware-clock.enable = false;

  # Networking
  networking = {
    networkmanager.enable = true;
    hostName = "${host}";
    timeServers = options.networking.timeServers.default ++ ["pool.ntp.org"];
  };

  # Set your time zone automatically based on IP location
  services.automatic-timezoned.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Services to start
  services = {
    xserver = {
      enable = true; # enabled for sddm / Xwayland
      xkb = {
        layout = "${keyboardLayout}";
        variant = "";
      };
    };

    # Enable SDDM display manager
    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
    };
    displayManager.ly.enable = lib.mkForce false;

    smartd = {
      enable = false;
      autodetect = true;
    };

    gvfs.enable = true;
    tumbler.enable = true;
    udisks2.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    udev.enable = true;
    envfs.enable = true;
    dbus.enable = true;

    fstrim = {
      enable = true;
      interval = "weekly";
    };

    libinput.enable = true;

    rpcbind.enable = true;
    nfs.server.enable = false;

    openssh.enable = true;
    flatpak.enable = true;

    blueman.enable = true;

    fwupd.enable = true;
    upower.enable = true;

    gnome.gnome-keyring.enable = true;

    # Enable PostgreSQL database service
    postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
    };
  };

  systemd.services.flatpak-repo = {
    path = [pkgs.flatpak];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  # zram swap - optimized for no hibernation
  zramSwap = {
    enable = true;
    priority = 100;
    memoryPercent = 50; # 50% RAM = optimal for zstd compression
    swapDevices = 1; # number of zram devices (1 is recommended)
    algorithm = "zstd"; # best compression ratio/speed balance
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };

  # Bluetooth
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
  };

  # Security / Polkit
  security = {
    rtkit.enable = true;
    polkit.enable = true;
    polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          subject.isInGroup("users")
            && (
              action.id == "org.freedesktop.login1.reboot" ||
              action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
              action.id == "org.freedesktop.login1.power-off" ||
              action.id == "org.freedesktop.login1.power-off-multiple-sessions"
            )
          )
        {
          return polkit.Result.YES;
        }
      });

      // Allow wheel group to mount system and external drives via udisks2 (Windows/Fedora drives in Nautilus)
      polkit.addRule(function(action, subject) {
        if (
          subject.isInGroup("wheel")
            && action.id.indexOf("org.freedesktop.udisks2.") === 0
        )
        {
          return polkit.Result.YES;
        }
      });
    '';
  };
  security.pam.services.swaylock = {
    text = ''
      auth include login
    '';
  };
  # Disable PAM fprint for hyprlock so its native parallel fingerprint auth works
  security.pam.services.hyprlock.fprintAuth = lib.mkForce false;
  # Custom PAM configuration for SDDM to swap password and fingerprint order
  # This allows pressing Enter on an empty password to activate fingerprint,
  # or typing a password and pressing Enter to login instantly without a 30s delay.
  security.pam.services.sddm.text = ''
    # Account management.
    account include login

    # Authentication management.
    auth sufficient ${pkgs.linux-pam}/lib/security/pam_unix.so likeauth nullok try_first_pass
    auth sufficient ${pkgs.fprintd}/lib/security/pam_fprintd.so
    auth include login

    # Password management.
    password include login

    # Session management.
    session include login
  '';
  security.pam.services.login.fprintAuth = lib.mkForce false;
  # Enable fprint for polkit-1 and sudo
  security.pam.services.polkit-1.fprintAuth = true;
  security.pam.services.sudo.fprintAuth = true;
  # Place fingerprint auth after password auth for sudo (order 11800 > unix order 11700)
  # This allows typing password + Enter for instant password auth, or Enter on blank to use fingerprint.
  security.pam.services.sudo.rules.auth.fprintd.order = 11800;

  # Nix configuration
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Limit parallel build resources to prevent RAM exhaustion and system crashes
      cores = 4; # Use 4 cores per build job (fulfills >= 4 cores requirement without overwhelming 8GB RAM)
      max-jobs = 1; # Build 1 package at a time to prevent concurrent heavy C++/Rust compilations

      substituters = [
        "https://cache.nixos.org?priority=10"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
        "https://ags.cachix.org"
        "https://catppuccin.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "ags.cachix.org-1:vuB2I3WFuTxn8KDRWYbPMC+FZELzyDH57wYUx438e6o="
        "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    optimise = {
      automatic = true;
      dates = ["weekly"];
    };
  };

  # OpenGL / graphics
  hardware.graphics = {
    enable = true;
  };

  console.keyMap = "${keyboardLayout}";

  # For Electron apps to use Wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  # For Hyprland QT Support
  environment.sessionVariables.QML_IMPORT_PATH = "${pkgs.hyprland-qt-support}/lib/qt-6/qml";

  # Enable nix-ld to run unpatched dynamic binaries (critical for Mason/VS Code LSPs)
  programs.nix-ld.enable = true;
  services.tailscale.enable = true;
  system.stateVersion = "26.05"; # Match target install
}
