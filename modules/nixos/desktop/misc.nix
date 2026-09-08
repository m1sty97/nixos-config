# =============================================================================
# modules/nixos/desktop/misc.nix — 桌面杂项配置
# -----------------------------------------------------------------------------
# 桌面环境常用的系统级设置：shell、字体、文件管理器等。
# =============================================================================
{
  lib,
  pkgs,
  ...
}:
{
  # 启动菜单等待时间（桌面可稍长，方便选择）
  boot.loader.timeout = lib.mkForce 10;

  # 将用户 shell 加入 /etc/shells
  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];

  # 系统默认 shell
  users.defaultUserShell = pkgs.zsh;

  # 修复 sudo 在 kitty/foot 等现代终端中的 terminfo 问题
  security.sudo.keepTerminfo = true;

  # 桌面基础包
  environment.systemPackages = with pkgs; [
    gnumake
    wl-clipboard # Wayland 剪贴板工具
  ];

  services = {
    # GVfs — 挂载、回收站等功能
    gvfs.enable = true;
    # Tumbler — 图片缩略图支持
    tumbler.enable = true;
  };

  programs = {
    # dconf — 低级配置系统（GNOME 系应用需要）
    dconf.enable = true;

    # Thunar 文件管理器
    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin # 压缩文件支持
        thunar-volman # 可移动设备管理
      ];
    };
  };
}
