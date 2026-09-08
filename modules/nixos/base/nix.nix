# =============================================================================
# modules/nixos/base/nix.nix — Nix 包管理器配置
# -----------------------------------------------------------------------------
# 启用 Flakes、自动垃圾回收、存储优化等。
# =============================================================================
{ lib, ... }:
{
  # 允许安装非自由软件（如 Chrome、VS Code 等）
  nixpkgs.config.allowUnfree = lib.mkForce true;

  # 每周自动垃圾回收，保留近 7 天的配置
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # Nix 守护进程设置
  nix.settings = {
    # 自动优化存储空间
    auto-optimise-store = true;

    # 启用 Flakes 和 nix-command 实验特性
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # 禁用 nix-channel，我们使用 flakes 管理依赖
  nix.channel.enable = false;
}
