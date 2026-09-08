# =============================================================================
# home/base/gui/desktop-tools.nix — 桌面工具
# -----------------------------------------------------------------------------
# Wayland 桌面环境下的常用工具。
# =============================================================================
{ pkgs, ... }:
{
  # Wayland 相关环境变量
  home.sessionVariables = {
    "NIXOS_OZONE_WL" = "1"; # Ozone-based 浏览器/Electron 应用使用 Wayland
    "MOZ_ENABLE_WAYLAND" = "1"; # Firefox 使用 Wayland
    "MOZ_WEBRENDER" = "1";
    "ELECTRON_OZONE_PLATFORM_HINT" = "auto"; # Electron 应用自动选择 Wayland
    "_JAVA_AWT_WM_NONREPARENTING" = "1"; # Java AWT 应用在 Wayland 下的修复
    "QT_WAYLAND_DISABLE_WINDOWDECORATION" = "1"; # Qt 禁用窗口装饰
    "SDL_VIDEODRIVER" = "wayland"; # SDL 使用 Wayland
    "GDK_BACKEND" = "wayland"; # GTK 使用 Wayland
    "XDG_SESSION_TYPE" = "wayland";
  };

  home.packages = with pkgs; [
    swaybg # 壁纸设置工具
    wl-clipboard # 剪贴板
    brightnessctl # 亮度控制
    hyprpicker # 取色器

    # 音频
    alsa-utils # amixer/alsamixer
    networkmanagerapplet # nm-connection-editor GUI

    # 截图工具
    grim # Wayland 截图
    slurp # 区域选择

    # 远程桌面
    remmina # RDP/VNC 客户端
    freerdp # RDP 库
  ];

  # ---------------------------------------------------------------------------
  # swaylock — 屏幕锁屏
  # ---------------------------------------------------------------------------
  programs.swaylock.enable = true;

  # ---------------------------------------------------------------------------
  # wlogout — 注销/电源菜单
  # ---------------------------------------------------------------------------
  programs.wlogout.enable = true;

  # ---------------------------------------------------------------------------
  # udiskie — USB 自动挂载
  # ---------------------------------------------------------------------------
  services.udiskie.enable = true;
}
