# =============================================================================
# home/base/core/theme.nix — Catppuccin 主题配置
# -----------------------------------------------------------------------------
# 使用 Catppuccin Macchiato 主题统一所有应用的配色。
# =============================================================================
{ catppuccin, ... }:
{
  # 导入 catppuccin 的 home-manager 模块
  imports = [
    catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    # 为所有支持的应用启用 catppuccin 主题
    enable = true;
    # 使用 Macchiato 风格（中等深度，适合屏幕阅读）
    flavor = "macchiato";
  };
}
