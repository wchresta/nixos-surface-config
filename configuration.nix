# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./surface.nix
      ./secrets.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = ...; # defined in secrets.nix
  # networking.networkmanager.enable = true;
  networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # if nothing else is defined, /etc/wpa_supplement.conf is used.
  # it contains the wifi passwords generated by wpa_passphrase

  # non hardware specific hardware options
  hardware = {
    pulseaudio.enable = true;
    pulseaudio.package = pkgs.unstable.pulseaudioFull;
#    pulseaudio.package = pkgs.pulseaudioFull;
    bluetooth.enable = true;
    opengl.driSupport = true;
    opengl.driSupport32Bit = true;
  };

  # Select internationalisation properties.
  i18n = {
  #   consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "sg-latin1";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  nixpkgs.config = {
    allowUnfree = true;

    # Allows usage of unstable in package list
    packageOverrides = pkgs: {
      unstable = import <nixos-unstable> {
        config = config.nixpkgs.config;
      };
    };
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment = {
    systemPackages = 
      let nvimPackages = (import ./customisation/nvimPackages.nix pkgs);
      in nvimPackages ++ (with pkgs; 
      [ nix-repl
        wget 
        firefox
        gparted
        powertop
        compton # a window composer, allowing us transparency without KWin
        unstable.kitty # a nice 24-bit colour shell
        alacritty
        jq # to parse JSON in bash
        file # just a generally useful tool
        tree # nicely visualise folder structures
  #      xfce.terminal
  #      unstable.xfce.xfce4volumed_pulse
        #networkmanager
        #networkmanagerapplet
        python
        mcron # we want to be able to run cronjobs

        powerline-fonts
        #python36Packages.powerline # Too slow

        bash-completion
        steam
        lxappearance
        gitAndTools.gitFull

        irssi
        unstable.haskellPackages.glirc

        unstable.cabal-install
        unstable.cabal2nix
        unstable.ghc
        unstable.stack

  #      haskellPackages.xmobar
  #      i3status
        
        fira
        fira-code
        fira-code-symbols
        fira-mono
        dejavu_fonts
        fantasque-sans-mono
      ]);

    shellAliases = {
      vi = "nvim";
      svi = "sudo nvim";
      enix = "sudo nvim /etc/nixos/configuration.nix";
      ehnix = "sudo nvim /etc/nixos/hardware-configuration.nix";
      evim = "sudo nvim /etc/nixos/customisation/nvimPackages.nix";
      enixtest = "sudo nixos-rebuild test";
      enixapply = "sudo nixos-rebuild switch";
    };

    variables = {
      EDITOR = "nvim";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash = {
    #enableCompletion = true; # this MAY slow down bash significantly

    # Enable airline-shellprompt prompt if it exists
    # Create this by running :PromptlineSnapshot ~/.airline-shellprompt.sh airline inside vim/neovim
    interactiveShellInit = ''
      if [ -f ~/.airline-shellprompt.sh ]; then
        source ~/.airline-shellprompt.sh
      fi
      '';
  };
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
 
  fonts.fontconfig.dpi = 140;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services.xserver = {
  # Enable the X11 windowing system.
    enable = true;
    layout = "ch";
    autorun = true;

    displayManager = {
      lightdm.enable = true;
    };
    desktopManager = {
      default = "plasma5";
      plasma5.enable = true;
      xfce.enable = false;
    };
    windowManager = {
      default = "xmonad";
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
      };
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "17.09"; # Did you read the comment?
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-17.09";
}
