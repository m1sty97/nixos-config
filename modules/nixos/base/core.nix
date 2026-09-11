# =============================================================================
# modules/nixos/base/core.nix — 核心启动配置
# -----------------------------------------------------------------------------
# GRUB2（UEFI）引导加载器设置，所有主机通用。
# =============================================================================
{ lib, ... }:
{
  boot.loader.grub = {
    enable = lib.mkDefault true;
    # UEFI 引导：device 设为 nodev 不写 MBR，通过 EFI 变量注册启动项
    device = lib.mkDefault "nodev";
    efiSupport = lib.mkDefault true;
  };

  # 允许安装时写入 EFI 启动项（需要 EFI 系统分区，见各主机 disko.nix）
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # 启动菜单等待时间（秒）
  boot.loader.timeout = lib.mkDefault 8;
}
