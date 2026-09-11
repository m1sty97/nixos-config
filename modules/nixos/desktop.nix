# =============================================================================
# modules/nixos/desktop.nix — 桌面主机入口模块
# -----------------------------------------------------------------------------
# 导入 base + desktop 模块，提供 Wayland 桌面环境的选项。
# 桌面主机在 outputs 中引用此模块。
# =============================================================================
{
  pkgs,
  config,
  lib,
  myvars,
  ...
}:
with lib;
let
  cfgWayland = config.modules.desktop.wayland;
in
{
  imports = [
    ./base
    ./desktop
  ];

  # ---------------------------------------------------------------------------
  # 选项：是否启用 Wayland 显示服务器
  # ---------------------------------------------------------------------------
  options.modules.desktop = {
    wayland = {
      enable = mkEnableOption "Wayland 显示服务器";
    };
  };

  config = mkMerge [
    (mkIf cfgWayland.enable {
      ####################################################################
      #  Wayland 桌面环境配置
      ####################################################################
      services = {
        # 禁用 Xorg
        xserver.enable = false;

        # greetd — 登录管理器，使用 tuigreet 提供 TUI 登录界面
        # 参考：https://sr.ht/~kennylevinsen/greetd
        greetd = {
          enable = true;
          settings = {
            default_session = {
              # 使用默认用户自动登录（可按需关闭）
              user = myvars.username;
              # 不带 --cmd 时 tuigreet 列出 /usr/share/wayland-sessions
              # 下的全部会话（niri / Hyprland），--remember-session 记住上次
              # 选择，实现登录时随时在多个合成器之间切换
              command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session";
            };
          };
        };
      };

      # swaylock 的 PAM 服务配置
      security.pam.services.swaylock = { };
    })
  ];
}
