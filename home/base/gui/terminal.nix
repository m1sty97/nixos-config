# =============================================================================
# home/base/gui/terminal.nix — 终端模拟器配置（Ghostty）
# -----------------------------------------------------------------------------
# Ghostty 是一个高性能的 GPU 加速终端模拟器，支持 Wayland 原生。
# 参考：https://ghostty.org/docs
# =============================================================================
{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # Ghostty 终端
  # 参考：https://ghostty.org/docs/config
  # ---------------------------------------------------------------------------
  programs.ghostty = {
    enable = true;

    # Ghostty 配置（通过 settings 以 key-value 写入）
    settings = {
      # 字体设置
      font-family = "JetBrainsMono Nerd Font";
      font-size = 14;

      # 主题（Catppuccin Macchiato）
      theme = "catppuccin-macchiato";

      # 窗口设置
      window-padding-x = 8;
      window-padding-y = 8;
      window-decoration = false; # Wayland 下由合成器管理装饰

      # 光标设置
      cursor-style = "block";
      cursor-style-blink = true;

      # 滚动设置
      scrollback-limit = 10000;

      # 透明度
      background-opacity = 0.95;
      background-blur-radius = 20;

      # Shell
      command = "zsh";

      # 复制时保留选中
      copy-on-select = "clipboard";

      # 鼠标
      mouse-hide-while-typing = true;

      # Mac Option 键作为 Alt（Linux 下不影响）
      macos-option-as-alt = true;
    };
  };

  # 额外的终端工具
  home.packages = with pkgs; [
    wl-clipboard # Wayland 剪贴板工具（Ghostty 复制粘贴需要）
  ];
}
