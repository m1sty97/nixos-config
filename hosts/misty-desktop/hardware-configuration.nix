# =============================================================================
# hosts/misty-desktop/hardware-configuration.nix — 硬件相关配置
# -----------------------------------------------------------------------------
# 磁盘分区与文件系统由 disko 声明式管理（见同目录 disko.nix），
# 挂载点（fileSystems）与交换分区由 disko 自动生成，此处不要重复定义。
# 本文件仅保留内核模块等硬件相关配置。
#
# 更换硬件后可运行以下命令重新生成，并将内核模块部分合并到本文件：
#   sudo nixos-generate-config --show-hardware-config
# =============================================================================
{ lib, ... }:
{
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "mptspi"
    "uhci_hcd"
    "ehci_pci"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
