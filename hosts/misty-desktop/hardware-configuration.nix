# =============================================================================
# hosts/misty-desktop/hardware-configuration.nix — 硬件配置占位文件
# -----------------------------------------------------------------------------
# ⚠️ 这是占位文件！
# 首次安装时，请在 NixOS Live 环境中运行以下命令生成真实的硬件配置：
#
#   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
#
# 然后将生成的文件复制到此处替换本文件。
#
# 生成的文件会包含：
#   - 文件系统挂载配置（fileSystems）
#   - 引导加载器配置（boot.loader）
#   - 内核模块（boot.initrd.kernelModules）
#   - 硬件特定的内核参数
# =============================================================================
{ ... }:
{
  # ---------------------------------------------------------------------------
  # 占位配置 — 请替换为实际硬件配置
  # ---------------------------------------------------------------------------

  # 引导加载器（UEFI 系统）
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # 基本文件系统（请根据实际情况修改）
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # 交换分区
  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];
}
