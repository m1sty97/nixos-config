# =============================================================================
# home/base/gui/browsers.nix — 浏览器配置
# -----------------------------------------------------------------------------
# Google Chrome 为主力浏览器，Firefox 为备用浏览器（仅桌面主机）。
# 通过 xdg.mimeApps 将 http/https 默认处理程序设为 Chrome。
# =============================================================================
{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # Google Chrome — 主力浏览器
  # ---------------------------------------------------------------------------
  programs.google-chrome = {
    enable = true;
  };

  # ---------------------------------------------------------------------------
  # Firefox — 备用浏览器
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

      # 扩展程序（extensions 为 submodule 结构，包列表在 packages 下）
      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin # 广告拦截
      ];
    };
  };

  # ---------------------------------------------------------------------------
  # 默认浏览器设为 Chrome
  # ---------------------------------------------------------------------------
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "google-chrome.desktop" ];
      "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      "x-scheme-handler/about" = [ "google-chrome.desktop" ];
      "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
    };
  };
}
