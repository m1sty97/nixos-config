# =============================================================================
# hosts/misty-hyprland/hardware-configuration.nix — 硬件配置占位文件
# -----------------------------------------------------------------------------
# ⚠️ 这是占位文件！
# 首次安装时，请在 NixOS Live 环境中运行以下命令生成真实的硬件配置：
#
#   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
#
# 引导配置（UEFI + GRUB2）由 modules/nixos/base/core.nix 统一提供，
# 此处无需（也不应）重复定义 boot.loader。
# =============================================================================
{ ... }:
{
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
