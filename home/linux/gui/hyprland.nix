# =============================================================================
# home/linux/gui/hyprland.nix — Hyprland 窗口管理器配置
# -----------------------------------------------------------------------------
# Hyprland 是一个动态平铺 Wayland 合成器。
# 参考：https://wiki.hyprland.org/
#
# 配置文件采用 dots-hyprland (illogical-impulse) 的 Lua DSL 格式：
#   - hyprland.lua       主入口（通过 require() 加载 hyprland/ 和 custom/ 模块）
#   - hyprland/          核心 Hyprland 配置（env/execs/general/keybinds/rules/variables）
#   - custom/            用户自定义覆盖（不会被更新覆盖，需要保持可写）
#   - hypridle.conf      空闲管理
#   - hyprlock.conf      锁屏
#
# ⚠️ 使用前需要：
#   1. 克隆 dots-hyprland 仓库并初始化子模块：
#      git clone --recurse-submodules <repo> ~/dots-hyprland
#      # 或已克隆后：cd ~/dots-hyprland && git submodule update --init
#   2. matugen 主题系统运行时写入 ~/.local/state/quickshell/user/generated/
#      确保该目录存在且可写（首次启动 matugen 会自动创建）
# =============================================================================
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.desktop.hyprland;
  dotsHyprDir = "${config.home.homeDirectory}/dots-hyprland/dots/.config";
in
{
  # ---------------------------------------------------------------------------
  # 选项：是否启用 Hyprland（home-manager 侧）
  # ---------------------------------------------------------------------------
  options.modules.desktop.hyprland = {
    enable = lib.mkEnableOption "Hyprland compositor (home-manager)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # Hyprland 相关工具
      hypridle
      hyprlock
      hyprpicker

      # 截图
      grim
      slurp

      # 剪贴板
      wl-clipboard
      cliphist

      # 壁纸
      hyprpaper
      swww

      # 其他
      brightnessctl
      matugen
    ];

    # ---------------------------------------------------------------------------
    # Hyprland 配置文件 — 链接 dots-hyprland 的配置到 ~/.config/
    # ---------------------------------------------------------------------------
    xdg.configFile = let
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
    in {
      "hypr/hyprland.lua".source = mkSymlink "${dotsHyprDir}/hypr/hyprland.lua";
      "hypr/hypridle.conf".source = mkSymlink "${dotsHyprDir}/hypr/hypridle.conf";
      "hypr/hyprlock.conf".source = mkSymlink "${dotsHyprDir}/hypr/hyprlock.conf";
      "hypr/hyprland".source = mkSymlink "${dotsHyprDir}/hypr/hyprland";
      "hypr/custom".source = mkSymlink "${dotsHyprDir}/hypr/custom";
      "quickshell".source = mkSymlink "${dotsHyprDir}/quickshell";
    };

    # ---------------------------------------------------------------------------
    # Wayland 会话启动脚本
    # ---------------------------------------------------------------------------
    home.file.".wayland-session" = {
      source = pkgs.writeScript "init-hyprland-session" ''
        #!/bin/sh
        exec /run/current-system/sw/bin/Hyprland
      '';
      executable = true;
    };

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
