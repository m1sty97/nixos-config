# =============================================================================
# modules/nixos/base/networking.nix — 基础网络配置
# -----------------------------------------------------------------------------
# 使用 NetworkManager 管理网络，DHCP 由 NM 的连接配置接管
# （networking.useDHCP 保持 nixpkgs 默认的 false，避免与 NM 冲突）。
# =============================================================================
{ lib, ... }:
{
  # 使用 NetworkManager 管理网络（提供 nmcli/nmtui 工具）
  networking.networkmanager.enable = lib.mkDefault true;
}
