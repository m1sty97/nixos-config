# =============================================================================
# modules/nixos/desktop/fonts.nix — 桌面字体配置
# -----------------------------------------------------------------------------
# 配置中文字体和等宽字体，确保中文显示正常。
# 字体包本身在 home-manager 中安装（home/base/core/theme.nix），
# 这里配置 fontconfig 默认字体顺序。
# =============================================================================
{ pkgs, ... }:
{
  fonts = {
    # 使用用户指定的字体而非默认字体
    enableDefaultPackages = false;
    fontDir.enable = true;

    # 系统级字体包（所有用户可用）
    packages = with pkgs; [
      # 西文字体
      source-serif-4 # 衬线
      source-sans-3 # 无衬线
      jetbrains-mono # 等宽
      nerd-fonts.jetbrains-mono # 等宽（Nerd Font 图标版，终端与 starship 使用）

      # 中文字体
      source-han-sans # 思源黑体（无衬线）
      source-han-serif # 思源宋体（衬线）
      source-han-mono # 思源等宽
      noto-fonts-cjk-sans # Noto CJK
      noto-fonts-emoji # Emoji 表情符号

      # 霞鹜文楷（适合屏幕阅读的中文楷体）
      lxgw-wenkai
    ];

    # fontconfig 字体匹配规则
    fontconfig = {
      defaultFonts = {
        # 衬线字体（宋体类）
        serif = [
          "Source Serif 4"
          "Source Han Serif SC"
          "Source Han Serif TC"
        ];
        # 无衬线字体（黑体类）
        sansSerif = [
          "Source Sans 3"
          "LXGW WenKai Screen"
          "Source Han Sans SC"
          "Source Han Sans TC"
        ];
        # 等宽字体
        monospace = [
          "JetBrainsMono Nerd Font"
          "Source Han Mono SC"
          "Source Han Mono TC"
        ];
        # Emoji
        emoji = [ "Noto Color Emoji" ];
      };
      antialias = true; # 抗锯齿
      hinting.enable = false; # 高分屏无需字体微调
      subpixel = {
        rgba = "rgb"; # IPS 屏幕使用 RGB 排列
      };
    };
  };
}
