# =============================================================================
# home/linux/gui/noctalia.nix — Noctalia 桌面 Shell 配置（Niri / Hyprland 共用）
# -----------------------------------------------------------------------------
# Noctalia 是一个原生 Wayland + OpenGL ES 的桌面 shell（非 Qt/Gtk），
# 提供：状态栏、启动器、通知中心、锁屏、壁纸、OSD、控制中心、剪贴板历史等。
#
# Noctalia 原生支持 Niri 和 Hyprland 的工作区集成，
# 通过 ext-workspace-v1 协议或 compositor-native backend 实现工作区指示器。
# 桌面主机（misty-desktop）的两个合成器统一使用 Noctalia 作为桌面 shell。
#
# 配置格式：TOML（通过 home-manager 的 programs.noctalia.settings 以 Nix attrset 写入）
# 配置参考：https://docs.noctalia.dev/noctalia/configuration/
# =============================================================================
{
  pkgs,
  config,
  lib,
  inputs,
  ...
}:
{
  # ---------------------------------------------------------------------------
  # 导入 Noctalia 的 home-manager 模块
  # ---------------------------------------------------------------------------
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # ---------------------------------------------------------------------------
  # Noctalia 配置
  # ---------------------------------------------------------------------------
  programs.noctalia = {
    enable = true;

    # 启用 systemd 用户服务（随图形会话自动启动）
    systemd.enable = true;

    # Noctalia 配置 — TOML 格式，通过 Nix attrset 写入
    # 完整配置参考：https://docs.noctalia.dev/noctalia/configuration/
    # 运行时也可通过 Noctalia 的设置 GUI 修改，会覆盖此处的值
    settings = {
      # ── Shell 基础设置 ──
      shell = {
        font_family = "JetBrainsMono Nerd Font";
        time_format = "{:%H:%M}";
        date_format = "%A, %x";
        settings_show_advanced = true;
        clipboard_enabled = true;
        clipboard_history_max_entries = 100;
      };

      # ── 主题 ──
      theme = {
        mode = "dark"; # dark | light | auto
        source = "builtin"; # builtin | wallpaper | community
        builtin = "Catppuccin"; # Ayu | Catppuccin | Dracula | Eldritch | Gruvbox | Kanagawa | Noctalia | Nord | Rosé Pine | Tokyo-Night
      };

      # ── 状态栏 ──
      bar.main = {
        position = "top";
        thickness = 34;
        background_opacity = 1.0;
        radius = 12;
        margin_ends = 180;
        margin_edge = 10;
        padding = 14;
        widget_spacing = 6;
        auto_hide = false;
        reserve_space = true;

        # 栏组件布局
        start = [ "launcher" "wallpaper" "workspaces" ];
        center = [ "clock" ];
        end = [
          "media"
          "tray"
          "notifications"
          "clipboard"
          "network"
          "bluetooth"
          "volume"
          "battery"
          "control-center"
          "session"
        ];
      };

      # ── 通知 ──
      notification = {
        enable_daemon = true;
        show_app_name = true;
        show_actions = true;
        background_opacity = 0.97;
      };

      # ── 锁屏 ──
      lockscreen = {
        enabled = true;
        blurred_desktop = false;
      };

      # ── OSD（屏幕显示）──
      osd = {
        position = "top_right";
        scale = 1.0;
        background_opacity = 0.97;
      };

      # ── 壁纸 ──
      wallpaper = {
        enabled = true;
        fill_mode = "crop"; # center | crop | fit | stretch | repeat | span
        directory = ""; # 空 = XDG Pictures 目录
      };

      # ── 系统监控 ──
      system.monitor = {
        enabled = true;
        cpu_poll_seconds = 2.0;
        memory_poll_seconds = 2.0;
        network_poll_seconds = 3.0;
      };

      # ── 启动器 ──
      shell.launcher = {
        categories = true;
        show_icons = true;
        sort_by_usage = true;
        pinned = [
          "ghostty"
          "firefox"
          "thunar"
        ];
      };

      # ── 音频 ──
      audio = {
        enable_overdrive = false;
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Noctalia 运行时依赖的工具包
  # ---------------------------------------------------------------------------
  home.packages = with pkgs; [
    # 截图/区域选择
    grim
    slurp

    # 壁纸相关
    # Noctalia 自带壁纸功能，但可选安装额外工具

    # 字体（Noctalia 使用 JetBrainsMono Nerd Font）
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # ---------------------------------------------------------------------------
  # Noctalia 的 Qt 环境变量不需要（Noctalia 是原生 Wayland+OpenGL ES，非 Qt）
  # ---------------------------------------------------------------------------
}
