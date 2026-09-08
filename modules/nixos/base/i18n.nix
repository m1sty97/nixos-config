# =============================================================================
# modules/nixos/base/i18n.nix — 国际化与本地化配置
# -----------------------------------------------------------------------------
# 时区设为上海，界面语言为英文（避免翻译质量参差），区域设为中国。
# =============================================================================
{
  # 系统时区
  time.timeZone = "Asia/Shanghai";

  # 界面默认语言（英文优先，避免中文翻译质量参差不齐）
  i18n.defaultLocale = "en_US.UTF-8";

  # 各区域设置使用中文（中国）格式
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };
}
