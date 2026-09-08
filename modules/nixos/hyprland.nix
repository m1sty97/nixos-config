# =============================================================================
# modules/nixos/hyprland.nix — Hyprland 系统级模块
# -----------------------------------------------------------------------------
# 启用 Hyprland Wayland 合成器，配置系统级依赖。
# Hyprland 分支主机在 outputs 中引用此模块。
# =============================================================================
{
  pkgs,
  config,
  lib,
  inputs,
  myvars,
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
      programs.hyprland.enable = true;

      # 禁用 Xorg
      services.xserver.enable = false;

      # greetd 登录管理器
      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            user = myvars.username;
            # 使用 tuigreet 启动 Hyprland 会话
            command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd $HOME/.wayland-session";
          };
        };
      };

      # Hyprland 需要 polkit
      security.pam.services.hyprlock = { };
    })
  ];
}
