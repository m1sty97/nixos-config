# =============================================================================
# modules/nixos/desktop/virtualisation.nix — 桌面虚拟化配置
# -----------------------------------------------------------------------------
# 桌面主机上的 QEMU/KVM 虚拟化支持。
# 服务器级别的虚拟化客户机配置在 server/virtualisation.nix 中。
# =============================================================================
{ pkgs, ... }:
{
  # VFIO PCI 模块（用于 GPU 直通等场景）
  boot.kernelModules = [ "vfio-pci" ];

  # QEMU/KVM 主机虚拟化工具
  environment.systemPackages = with pkgs; [
    qemu_kvm

    # QEMU 全架构模拟（支持 ARM、RISC-V 等）
    qemu
  ];
}
