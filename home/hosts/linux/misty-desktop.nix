# =============================================================================
# home/hosts/linux/misty-desktop.nix — 桌面主机 Home Manager 配置
# -----------------------------------------------------------------------------
# 桌面主机同时安装 Niri 与 Hyprland 两个合成器，登录时通过
# greetd/tuigreet 的会话菜单选择进入哪个（见 modules/nixos/desktop.nix）。
# Noctalia Shell 与 fcitx5 为两个合成器共用（见 ../../linux/gui/default.nix）。
# =============================================================================
{ ... }:
{
  imports = [
    ../../linux/gui.nix

    # WM 模块显式导入（gui/default.nix 只导入共用的 GUI 配置）
    ../../linux/gui/niri.nix
    ../../linux/gui/hyprland.nix
  ];

  # ---------------------------------------------------------------------------
  # 启用 Niri 与 Hyprland（登录时选择会话）
  # ---------------------------------------------------------------------------
  modules.desktop.niri.enable = true;
  modules.desktop.hyprland.enable = true;
}
