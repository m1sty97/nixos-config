# =============================================================================
# modules/nixos/hyprland.nix — Hyprland 系统级模块
# -----------------------------------------------------------------------------
# 启用 Hyprland Wayland 合成器，配置系统级依赖。
# 由 misty-desktop 主机引用，与 Niri 共存；
# 登录时通过 greetd/tuigreet 的会话菜单选择进入哪个合成器。
# =============================================================================
{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfgHyprland = config.modules.desktop.hyprland;
in
{
  imports = [
    # 导入 Hyprland 的 NixOS 模块（来自 hyprland flake）
    inputs.hyprland.nixosModules.default
  ];

  # ---------------------------------------------------------------------------
  # 选项：是否启用 Hyprland
  # ---------------------------------------------------------------------------
  options.modules.desktop = {
    hyprland = {
      enable = mkEnableOption "Hyprland Wayland 合成器";
    };
  };

  config = mkMerge [
    (mkIf cfgHyprland.enable {
      ####################################################################
      #  Hyprland 系统级配置
      ####################################################################

      # 启用 Hyprland（通过 hyprland flake 的 NixOS 模块）
      # 登录管理器（greetd）与 Xorg 开关由 desktop.nix 统一配置，此处不重复
      programs.hyprland.enable = true;

      # Hyprland 需要 polkit
      security.pam.services.hyprlock = { };
    })
  ];
}
