# =============================================================================
# home/base/core/xdg.nix — XDG 用户目录配置
# -----------------------------------------------------------------------------
# 设置 XDG 标准目录路径，避免在主目录产生散乱文件。
# =============================================================================
{ config, ... }:
{
  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };
}
