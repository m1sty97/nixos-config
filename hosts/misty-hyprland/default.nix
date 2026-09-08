# =============================================================================
# hosts/misty-hyprland/default.nix — Hyprland 桌面主机配置
# -----------------------------------------------------------------------------
# 使用 Hyprland + dots-hyprland (illogical-impulse) 的桌面主机。
#
# 使用前需要将 dots-hyprland 仓库克隆到 ~/dots-hyprland：
#   git clone <dots-hyprland 仓库地址> ~/dots-hyprland
#
# 硬件相关配置（hardware-configuration.nix）需要根据实际硬件生成：
#   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
# =============================================================================
{
  myvars,
  lib,
  pkgs,
  ...
}:
let
  hostName = "misty-hyprland";
in
{
  imports = [
    # 硬件配置
    ./hardware-configuration.nix
  ];

  # ---------------------------------------------------------------------------
  # 网络配置
  # ---------------------------------------------------------------------------
  networking = {
    inherit hostName;
    networkmanager.enable = true;
    useDHCP = true;
  };

  # ---------------------------------------------------------------------------
  # 启用 Hyprland
  # ---------------------------------------------------------------------------
  modules.desktop.hyprland.enable = true;

  # ---------------------------------------------------------------------------
  # 桌面环境选项
  # ---------------------------------------------------------------------------
  modules.desktop.wayland.enable = true;

  # ---------------------------------------------------------------------------
  # 系统状态版本
  # ---------------------------------------------------------------------------
  system.stateVersion = "25.05";
}
