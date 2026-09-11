# =============================================================================
# hosts/misty-server/default.nix — 服务器主机配置
# -----------------------------------------------------------------------------
# 运行在虚拟化环境中的服务器主机（如 KubeVirt/Proxmox/QEMU 中的 VM）。
# 提供基础服务器工具，便于后续部署各种服务。
#
# 硬件相关配置需要根据实际硬件生成：
#   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
# =============================================================================
{
  myvars,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  hostName = "misty-server";
in
{
  imports = [
    # 磁盘分区声明 — 由 disko 声明式管理，自动生成 fileSystems
    inputs.disko.nixosModules.default
    ./disko.nix

    # 硬件配置
    ./hardware-configuration.nix

    # QEMU 客户机配置（作为虚拟机运行时需要）
    ../../modules/nixos/server/qemu-guest.nix
  ];

  # ---------------------------------------------------------------------------
  # 网络 — 服务器使用 NetworkManager（与 base 默认一致，便于虚拟化环境中自动获取 IP）
  # base/networking.nix 已默认启用 NetworkManager + DHCP，此处仅设置主机名
  # ---------------------------------------------------------------------------
  networking.hostName = hostName;

  # ---------------------------------------------------------------------------
  # 系统状态版本
  # ---------------------------------------------------------------------------
  system.stateVersion = "26.05";
}
