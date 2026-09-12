# =============================================================================
# home/linux/gui/hyprland.nix — Hyprland 窗口管理器配置
# -----------------------------------------------------------------------------
# Hyprland 是一个动态平铺 Wayland 合成器。
# 参考：https://wiki.hyprland.org/
#
# 桌面 Shell 统一使用 Noctalia（与 Niri 共用），原生支持 Hyprland。
# Hyprland 配置通过 xdg.configFile 写入 ~/.config/hypr/hyprland.conf，
# 在配置中 spawn-at-startup 启动 Noctalia。
# =============================================================================
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.desktop.hyprland;
in
{
  # ---------------------------------------------------------------------------
  # 选项：是否启用 Hyprland（home-manager 侧）
  # ---------------------------------------------------------------------------
  options.modules.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland compositor (home-manager)";
  };

  config = lib.mkIf cfg.enable {
    # Hyprland 本体与依赖（polkit 等）由系统级模块（modules/nixos/hyprland.nix）
    # 启用；截图/剪贴板/亮度等工具由 desktop-tools.nix 统一安装，此处不重复。
    #
    # ---------------------------------------------------------------------------
    # Hyprland 配置文件 — 写入 ~/.config/hypr/hyprland.conf
    # 参考：https://wiki.hyprland.org/Configuring/
    # ---------------------------------------------------------------------------
    xdg.configFile."hypr/hyprland.conf".text = ''
      # =============================================================================
      # Hyprland 配置 — 由 home-manager 生成
      # =============================================================================

      # ── 环境变量 ──
      env = XDG_CURRENT_DESKTOP,Hyprland
      env = XDG_SESSION_TYPE,wayland
      env = XDG_SESSION_DESKTOP,Hyprland
      env = QT_QPA_PLATFORM,wayland;xcb
      env = MOZ_ENABLE_WAYLAND,1
      env = NIXOS_OZONE_WL,1
      env = ELECTRON_OZONE_PLATFORM_HINT,auto

      # ── 输入设备 ──
      input {
          kb_layout = us
          follow_mouse = 1
          touchpad {
              natural_scroll = yes
              clickfinger_behavior = true
          }
          sensitivity = 0
      }

      # ── 布局 ──
      general {
          gaps_in = 8
          gaps_out = 12
          border_size = 2
          # catppuccin macchiato 蓝色边框
          col.active_border = rgba(8aadf4ff)
          col.inactive_border = rgba(494d64ff)
          layout = dwindle
      }

      decoration {
          rounding = 10
          blur {
              enabled = true
              size = 3
              passes = 1
          }
          drop_shadow = yes
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(1e1e2eff)
      }

      animations {
          enabled = yes
          bezier = easeOut, 0.05, 0.9, 0.1, 1.05
          animation = windows, 1, 5, easeOut, slide
          animation = windowsOut, 1, 5, easeOut, slide
          animation = borders, 1, 8, default
          animation = fade, 1, 5, default
          animation = workspaces, 1, 5, easeOut, slide
      }

      dwindle {
          pseudotile = yes
          preserve_split = yes
      }

      # ── 启动时执行 ──
      exec-once = noctalia
      exec-once = fcitx5 -d --replace

      # ── 快捷键 ──
      # Mod 键 = Super
      $mod = SUPER

      # 应用启动
      bind = $mod, T, exec, ghostty
      bind = $mod, W, exec, google-chrome-stable
      bind = $mod, E, exec, thunar
      bind = $mod, D, exec, noctalia msg launcher-toggle

      # 窗口管理
      bind = $mod, Q, killactive,
      bind = $mod, F, fullscreen,
      bind = $mod, Space, togglefloating,
      bind = $mod, Return, togglesplit,

      # 焦点移动
      bind = $mod, left, movefocus, l
      bind = $mod, right, movefocus, r
      bind = $mod, up, movefocus, u
      bind = $mod, down, movefocus, d

      # 移动窗口
      bind = $mod SHIFT, left, movewindow, l
      bind = $mod SHIFT, right, movewindow, r
      bind = $mod SHIFT, up, movewindow, u
      bind = $mod SHIFT, down, movewindow, d

      # 工作区
      bind = $mod, 1, workspace, 1
      bind = $mod, 2, workspace, 2
      bind = $mod, 3, workspace, 3
      bind = $mod, 4, workspace, 4
      bind = $mod, 5, workspace, 5
      bind = $mod, 6, workspace, 6
      bind = $mod, 7, workspace, 7
      bind = $mod, 8, workspace, 8
      bind = $mod, 9, workspace, 9
      bind = $mod, 0, workspace, 10

      bind = $mod SHIFT, 1, movetoworkspace, 1
      bind = $mod SHIFT, 2, movetoworkspace, 2
      bind = $mod SHIFT, 3, movetoworkspace, 3
      bind = $mod SHIFT, 4, movetoworkspace, 4
      bind = $mod SHIFT, 5, movetoworkspace, 5
      bind = $mod SHIFT, 6, movetoworkspace, 6
      bind = $mod SHIFT, 7, movetoworkspace, 7
      bind = $mod SHIFT, 8, movetoworkspace, 8
      bind = $mod SHIFT, 9, movetoworkspace, 9
      bind = $mod SHIFT, 0, movetoworkspace, 10

      # 工作区滚动
      bind = $mod, mouse_down, workspace, e+1
      bind = $mod, mouse_up, workspace, e-1

      # 会话
      bind = $mod, L, exec, hyprlock
      bind = $mod SHIFT, E, exit,
      bind = $mod SHIFT, R, exec, noctalia msg restart

      # 截图
      bind = , Print, exec, grim -g "$(slurp)" - | wl-copy

      # 音量（需要 pactl）
      bind = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
      bind = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
      bind = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%

      # 媒体控制
      bind = , XF86AudioPlay, exec, playerctl play-pause
      bind = , XF86AudioNext, exec, playerctl next
      bind = , XF86AudioPrev, exec, playerctl previous

      # ── 窗口规则 ──
      windowrule = float, ^(dialog)$
      windowrule = float, ^(popup)$
      windowrule = float, ^(file-chooser)$

      # ── 修饰键 ──
      gestures {
          workspace_swipe = true
          workspace_swipe_forever = true
      }

      # ── 杂项 ──
      misc {
          disable_hyprland_logo = true
          disable_splash_rendering = true
          focus_on_activate = true
      }
    '';

    # ---------------------------------------------------------------------------
    # Hyprland 环境变量
    # ---------------------------------------------------------------------------
    home.sessionVariables = {
      "XDG_CURRENT_DESKTOP" = "Hyprland";
      "XDG_SESSION_TYPE" = "wayland";
      "XDG_SESSION_DESKTOP" = "Hyprland";
    };
  };
}
