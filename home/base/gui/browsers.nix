# =============================================================================
# home/base/gui/browsers.nix — 浏览器配置
# -----------------------------------------------------------------------------
# Firefox 和 Chrome 作为默认浏览器。
# =============================================================================
{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # Firefox — 主力浏览器
  # ---------------------------------------------------------------------------
  programs.firefox = {
    enable = true;

    # 配置文件设置
    profiles.default = {
      # 用户偏好设置
      settings = {
        # 启用 Wayland 原生支持
        "widget.use-xdg-desktop-portal.file-picker" = 1;
        # 禁用遥测
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        # 首页设置
        "browser.startup.homepage" = "https://www.google.com";
        # 下载行为：询问保存位置
        "browser.download.useDownloadDir" = false;
      };

      # 扩展程序
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin # 广告拦截
        catppuccin-gh-stars # GitHub 主题（可选）
      ];
    };
  };

  # ---------------------------------------------------------------------------
  # Google Chrome — 备用浏览器
  # ---------------------------------------------------------------------------
  programs.google-chrome = {
    enable = true;
  };
}
