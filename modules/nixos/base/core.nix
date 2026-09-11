# =============================================================================
# modules/nixos/base/core.nix — 核心启动配置
# -----------------------------------------------------------------------------
# systemd-boot 引导加载器的基本设置，所有主机通用。
# =============================================================================
{ lib, ... }:
{
  boot.loader.systemd-boot = {
    # UEFI 主机默认启用 systemd-boot（服务器虚拟机使用 GRUB，
    # 在 qemu-guest.nix 中 mkForce 关闭）
    enable = lib.mkDefault true;
    # 使用 Git 做版本控制，保留 10 代系统配置即可
    configurationLimit = lib.mkDefault 10;
    # 控制台使用最高分辨率
    consoleMode = lib.mkDefault "max";
  };

  # 允许安装时写入 EFI 启动项
  boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;

  # 启动菜单等待时间（秒）
  boot.loader.timeout = lib.mkDefault 8;
}
