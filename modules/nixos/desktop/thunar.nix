# =============================================================================
# modules/nixos/desktop/thunar.nix — 文件管理器（Thunar）
# -----------------------------------------------------------------------------
# 桌面主机的图形文件管理器。Niri 与 Hyprland 的 Mod+E 快捷键
# 均绑定 `thunar`，必须系统级启用才能生效。
# 同时启用 gvfs 提供回收站、网络位置、U 盘自动挂载等能力。
# =============================================================================
{ pkgs, ... }:
{
  programs.thunar = {
    enable = true;
    # 归档管理插件（右键解压/压缩）
    plugins = with pkgs; [
      thunar-archive-plugin
    ];
  };

  # GVfs — Thunar 的回收站/网络位置/U 盘挂载依赖
  services.gvfs.enable = true;

  # thunar-archive-plugin 依赖的解压后端
  environment.systemPackages = with pkgs; [
    xarchiver
  ];
}
