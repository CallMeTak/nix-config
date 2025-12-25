# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ../../modules/common/nixos
    ../../modules/common/nixos/desktop/hyprland
  ];
  boot.kernelParams = [
    "nvme_core.default_ps_max_latency_us=0"
    #  "nvidia-drm.modeset=0"
  ];
  boot.extraModulePackages = [
    pkgs.linuxKernel.packages.linux_6_12.lenovo-legion-module
  ];
  hardware.nvidia.prime.amdgpuBusId = lib.mkForce "PCI:6:0:0";

  networking.hostName = "Legion-NixOS"; # Define your hostname.
  environment.variables = {
    WLR_DRM_DEVICES = "/dev/dri/card1";
  };
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";
  #  services.xserver.dpi = 180;
  # HIDPI
  #  environment.variables = {
  #   GDK_SCALE = "2";
  #   GDK_DPI_SCALE = "0.5";
  #   _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
  # };

  programs.firefox.enable = true;
  environment.systemPackages = with pkgs; [
    lenovo-legion
  ];

  services.udev.extraRules = ''
    ENV{DEVNAME}=="/dev/dri/card1", TAG+="mutter-device-preferred-primary"
  '';
  specialisation = {
    vm = {
      inheritParentConfig = true;
      configuration =
        let
          user = "tak";
          # Change this to match your system's CPU.
          platform = "amd";
          # Change this to specify the IOMMU ids you wrote down earlier.
          vfioIds = [
            "10de:2560"
            "10de:228e"
          ];
        in
        {
          hardware.nvidia.powerManagement.finegrained = lib.mkForce true;
          hardware.amdgpu.initrd.enable = lib.mkForce true;
          security.pam.loginLimits = [
            {
              domain = "libvirtd"; # Apply to the libvirt-qemu group
              type = "hard";
              item = "memlock";
              value = "unlimited";
            }
            {
              domain = "libvirtd";
              type = "soft";
              item = "memlock";
              value = "unlimited";
            }
            {
              domain = "${user}"; # Apply to the libvirt-qemu group
              type = "hard";
              item = "memlock";
              value = "unlimited";
            }
            {
              domain = "${user}";
              type = "soft";
              item = "memlock";
              value = "unlimited";
            }
          ];
          fileSystems."/dev/hugepages" = {
            device = "none";
            fsType = "hugetlbfs";
            options = [
              "mode=1770"
              "gid=kvm"
            ];
          };
          boot = {
            kernelModules = [
              "kvm-${platform}"
              "vfio_pci"
              "vfio_iommu_type1"
              "vfio"
            ];
            initrd.kernelModules = [ "vfio-pci" ];
            # config.boot.kernelParams ++
            kernelParams = [
              "${platform}_iommu=on"
              "${platform}_iommu=pt"
              "kvm.ignore_msrs=1"
              "transparent_hugepage=madvise"
            ];
            extraModprobeConfig = lib.mkMerge [
              config.boot.extraModprobeConfig
              ''
                options vfio-pci ids=${builtins.concatStringsSep "," vfioIds}
              ''
            ];
          };

          systemd.tmpfiles.rules = [
            "f /dev/shm/looking-glass 0660 ${user} qemu-libvirtd -"

          ];
          #systemd.services.gdm.environment = {
          #  "WLR_DRM_DEVICES" = "/dev/dri/card1"; # Adjust if `card0` isn't your AMD iGPU
          #};
          environment.systemPackages = with pkgs; [
            virt-manager
            looking-glass-client
            swtpm
            tpm2-tools
            tpm2-tss
            virtiofsd
          ];
          systemd.services.libvirtd = {
            serviceConfig = {
              LimitMEMLOCK = "infinity"; # Allow unlimited locked memory
            };
          };

          services.udev.extraRules =
            config.services.udev.extraRules
            + ''
              KERNEL=="vfio", GROUP="kvm", MODE="0660"
              KERNEL=="vfio/*", GROUP="kvm", MODE="0660"

              SUBSYSTEM=="vfio", KERNEL=="[0-9]*", GROUP="kvm", MODE="0660"

              KERNEL=="bus/usb/*", GROUP="kvm", MODE="0660"
              KERNEL=="event*", SUBSYSTEM=="input", GROUP="kvm", MODE="0660"
              SUBSYSTEM=="usb", GROUP="kvm", MODE="0660"

              SUBSYSTEM=="pci", OWNER="root", GROUP="kvm", MODE="0660"
              SUBSYSTEM=="pci", ATTRS{vendor}=="0x8086", ATTRS{device}=="0x10de", ATTR{driver_override}="vfio-pci", OWNER="root", GROUP="kvm", MODE="0660"

            '';
          virtualisation.libvirtd = {
            enable = true;

            extraConfig = ''
              user="${user}"
            '';
            onBoot = "ignore";
            onShutdown = "shutdown";
            qemu = {
              runAsRoot = true;
              swtpm.enable = true;
              package = pkgs.qemu_kvm;

            };
          };

          users.users.${user}.extraGroups = [
            "kvm"
            "qemu-libvirtd"
            "libvirtd"
            "disk"
          ];
        };
    };
  };
  system.stateVersion = "24.11"; # Did you read the comment?

}
