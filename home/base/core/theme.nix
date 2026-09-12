# =============================================================================
# home/base/core/theme.nix — Catppuccin 主题配置
# -----------------------------------------------------------------------------
# 使用 Catppuccin Macchiato 主题统一所有应用的配色。
# =============================================================================
{ lib, config, catppuccin, ... }:
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

    # Firefox 主题关闭：其 FirefoxColor 扩展引用的 addon 包需要在
    # 求值期构建，与 `nix flake check --no-build` 快速门禁冲突。
    # mkIf 保证仅在有 Firefox 的主机（桌面）上定义该 profile，
    # 服务器上不会出现无谓的定义告警。
    firefox.profiles.default.enable = lib.mkIf config.programs.firefox.enable false;
    # swaylock 主题同理：转换配置需要求值期 derivation
    swaylock.enable = false;
  };
}
