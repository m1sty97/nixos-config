# =============================================================================
# hosts/misty-hyprland/hardware-configuration.nix — 硬件配置占位文件
# -----------------------------------------------------------------------------
# ⚠️ 这是占位文件！
# 首次安装时，请在 NixOS Live 环境中运行以下命令生成真实的硬件配置：
#
#   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
# =============================================================================
{ ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];
}
