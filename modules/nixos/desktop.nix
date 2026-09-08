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
              # tuigreet 启动 Wayland 会话
              # .wayland-session 由 home-manager 生成，链接到当前 Wayland 合成器
              command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd $HOME/.wayland-session";
            };
          };
        };
      };

      # swaylock 的 PAM 服务配置
      security.pam.services.swaylock = { };
    })
  ];
}
