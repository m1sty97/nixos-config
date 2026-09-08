# =============================================================================
# home/linux/gui/fcitx5.nix — Fcitx5 输入法配置
# -----------------------------------------------------------------------------
# Fcitx5 + Rime 输入法框架，用于中文输入。
# Wayland 原生前端，支持在 Niri 等 Wayland 合成器中使用。
# =============================================================================
{ pkgs, ... }:
{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    fcitx5 = {
      # Wayland 原生前端
      waylandFrontend = true;

      # 输入法插件
      addons = with pkgs; [
        # GUI 配置工具
        qt6Packages.fcitx5-configtool

        # GTK 输入法模块（使 GTK 应用支持 fcitx5）
        fcitx5-gtk

        # 中文输入法 — Rime（小鹤音形等方案）
        fcitx5-rime

        # 中文输入法 — 拼音（如不使用 Rime 可启用此项）
        # fcitx5-chinese-addons
      ];
    };
  };
}
