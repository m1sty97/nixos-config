# =============================================================================
# modules/nixos/base/snapper.nix — btrfs 定时快照（Snapper）
# -----------------------------------------------------------------------------
# 全主机统一：disko 布局保证各主机均为 @/ @home @nix 子卷，
# 故快照策略可放在 base 层一份通用。
#
# 范围：/（系统、/etc、/var/lib——含 sops 私钥与 AI 服务数据）与 /home；
# /nix 不做快照——nix generations 本身即其回滚机制，避免双倍占用。
#
# 回滚备忘：
#   系统级 —— nix generations（GRUB 选旧代）
#   数据级 —— snapper list → snapper undochange <前ID>..<后ID>
# =============================================================================
{ lib, myvars, ... }:
{
  services.snapper.configs = {
    root = {
      SUBVOLUME = "/";
      ALLOW_USERS = [ myvars.username ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 8;
      TIMELINE_LIMIT_DAILY = 7;
      TIMELINE_LIMIT_WEEKLY = 4;
      TIMELINE_LIMIT_MONTHLY = 0;
    };
    home = {
      SUBVOLUME = "/home";
      ALLOW_USERS = [ myvars.username ];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_HOURLY = 12;
      TIMELINE_LIMIT_DAILY = 14;
      TIMELINE_LIMIT_WEEKLY = 8;
      TIMELINE_LIMIT_MONTHLY = 2;
    };
  };
}
