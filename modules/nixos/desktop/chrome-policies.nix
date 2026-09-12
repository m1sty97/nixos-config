# =============================================================================
# modules/nixos/desktop/chrome-policies.nix — Chrome 扩展策略
# -----------------------------------------------------------------------------
# Linux 上 Chrome 不接受 home-manager 式的扩展注入，只能从系统策略目录
# /etc/opt/chrome/policies/managed/ 加载外部扩展，此处以企业策略
# ExtensionInstallForcelist 声明式强装 uBlock Origin Lite（去广告）。
# Chrome 已下架 MV2 的原版 uBlock Origin，MV3 环境使用 Lite 版。
# =============================================================================
{ ... }:
{
  environment.etc."opt/chrome/policies/managed/ublock-origin-lite.json".text =
    builtins.toJSON {
      ExtensionInstallForcelist = [
        "ddbahbpljcahncdlkdaljbgleeagekfc;https://clients2.google.com/service/update2/crx"
      ];
    };
}
