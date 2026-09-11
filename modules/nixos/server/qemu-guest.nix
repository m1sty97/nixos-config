# =============================================================================
# modules/nixos/server/qemu-guest.nix — QEMU/KVM 虚拟机客户机配置
# -----------------------------------------------------------------------------
# 当服务器作为虚拟机运行在 KubeVirt/Proxmox 等平台上时使用。
# 如服务器是物理机，则不需要导入此模块。
# =============================================================================
{
  modulesPath,
  lib,
  ...
}:
{
  imports = [
    # NixOS 自带的 QEMU 客户机 profile
    "${toString modulesPath}/profiles/qemu-guest.nix"
  ];

  config = {
    # 自动扩展根分区
    boot.growPartition = true;
    # 串口控制台输出（KubeVirt/Proxmox 需要）
    boot.kernelParams = [ "console=ttyS0" ];
    # GRUB 引导设备
    boot.loader.grub.device = "/dev/vda";
    # 虚拟机使用 GRUB/BIOS 引导，关闭 base 默认启用的 systemd-boot
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce false;

    # QEMU Guest Agent — 虚拟化管理平台需要
    services.qemuGuest.enable = true;
    services.openssh.enable = true;
    # 禁用 cloud-init，我们用 NixOS 配置管理
    services.cloud-init.enable = lib.mkForce false;
    # 串口终端
    systemd.services."serial-getty@ttyS0".enable = true;
  };
}
