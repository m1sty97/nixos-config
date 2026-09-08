# =============================================================================
# modules/nixos/base/networking.nix — 基础网络配置
# -----------------------------------------------------------------------------
# 使用 NetworkManager 管理网络，桌面主机默认开启。
# 服务器主机可覆盖为 systemd-networkd 静态 IP 配置。
# =============================================================================
{ lib, ... }:
{
  # 使用 NetworkManager 管理网络（提供 nmcli/nmtui 工具）
  networking.networkmanager.enable = lib.mkDefault true;

  # 默认使用 DHCP
  networking.useDHCP = lib.mkDefault true;
}
