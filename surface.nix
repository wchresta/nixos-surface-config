{ config, pkgs, ... }:
rec {
  services.xserver.synaptics = {
    enable = true;
    twoFingerScroll = true;
    palmDetect = false;
    buttonsMap = [ 1 3 2 ];
    fingersMap = [ 1 3 2 ];
    minSpeed = "0.8";
    maxSpeed = "1.4";
    additionalOptions = ''
    MatchDevicePath "/dev/input/event*"
    Option "vendor" "045e"
    Option "product" "07e2"
    '';
  };

  boot.kernelModules = [ "hid-multitouch" ];
  boot.initrd.kernelModules = [ "hid-multitouch" ];
  boot.loader.grub.enable = false;
  #boot.loader.gummiboot.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #suspend if powerbutton his bumped, rather than shutdown.
  services.logind.extraConfig = ''
    HandlePowerKey=suspend
    HandleLidSwitch=ignore
  '';

  powerManagement.enable = true;
  #powerManagement.powerUpCommands = "";
  #powerManagement.powerDwnCommands = "";
  powerManagement.cpuFreqGovernor = "powersave";

  boot.kernelPackages = pkgs.linuxPackages_4_4;
  nixpkgs.config.packageOverrides = pkgs: {
    linux_4_4 = pkgs.linux_4_4.override {
      kernelPatches = [
        { patch = ./linux_patches/multitouch.patch; name = "multitouch-type-cover";} 
        { patch = ./linux_patches/touchscreen_multitouch_fixes1.patch; name = "multitouch-fixes1";} 
        { patch = ./linux_patches/touchscreen_multitouch_fixes2.patch; name = "multitouch-fixes2";} 
        { patch = ./linux_patches/cam.patch; name = "surfacepro3-cameras"; }
        #{ patch = ./linux_patches/mwifiex_wakeup.patch; name = "mwifiex-wakeup-fix"; } # doesn't compile with 4.4
      ];
      extraConfig = ''
        I2C_DESIGNWARE_PLATFORM m
        X86_INTEL_LPSS y
      '';
    };
  };

  systemd = {
    timers.lidcheck = {
      partOf = [ "acpid.service"];
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnUnitActiveSec = "60";
        OnBootSec = "60";
      };
    };

    services = {
      lidcheck = {
        environment = { DISPLAY = ":0"; };
        description = "ensure sleep when unpowered and lid closed";
        script = services.acpid.lidEventCommands;
      };


      tune-power-management = {
        description = "Tune Power Management";
        wantedBy = [ "multi-user.target" ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };

        unitConfig.RequiresMountsFor = "/sys";
        script = ''
          echo 1 > /sys/module/snd_hda_intel/parameters/power_save
          for pci_device in \
            0000:00:02.0 \
            0000:00:03.0 \
            0000:00:1b.0 \
            0000:01:00.0 \
          ; do echo auto > /sys/bus/pci/devices/$pci_device/power/control; done
          for i2c_device in \
            i2c-0 \
            i2c-1 \
            i2c-2 \
            i2c-3 \
            i2c-4 \
            i2c-5 \
            i2c-6 \
            i2c-7 \
            i2c-8 \
            i2c-9 \
            i2c-10 \
          ; do echo auto > /sys/bus/i2c/devices/$i2c_device/device/power/control; done
          for knob in /sys/class/scsi_host/*/link_power_management_policy; do
            echo min_power > $knob
          done
          echo 1500 > /proc/sys/vm/dirty_writeback_centisecs
          echo auto > /sys/bus/usb/devices/1-3/power/control
          echo auto > /sys/bus/usb/devices/1-6/power/control
        '';
      };
    };
  };

  services.acpid.enable = true;
  #on lid event, lock if the lid is closed and we have power;
  # if closed and no power, sleep

  services.acpid.lidEventCommands = ''
    export PATH=/run/current-system/sw/bin
    LID_STATE=$(awk '{ print $2 }' /proc/acpi/button/lid/LID0/state)
    AC_STATE=$(cat /sys/class/power_supply/AC0/online)
    export DISPLAY=':0'
    if [ $LID_STATE = 'closed' ]; then
      xset dpms force off
      xautolock -locknow
      systemctl suspend
      if [ $AC_STATE = '0' ]; then
        systemctl suspend
      fi
    fi

  '';

  services.acpid.acEventCommands = ''
    export PATH=/run/current-system/sw/bin
    AC_STATE=$(cat /sys/class/power_supply/AC0/online)
    if [ $AC_STATE = '0' ]; then
      iw dev wlp1s0 set power_save on
    else
      iw dev wlp1s0 set power_save off
    fi
  '';

  # set power-management, inspired by powertop and ebzzry/dotfiles/blob/master/nixos/configuration.nix


}
