# =============================================================================
# flake.nix — 个人 NixOS 配置入口
# -----------------------------------------------------------------------------
# 本 flake 管理以下主机：
#   1. misty-desktop  — 日常使用桌面主机（Niri + Noctalia Shell）
#   2. misty-hyprland — Hyprland 桌面主机（Hyprland + Noctalia Shell）
#   3. misty-server   — 服务器主机（运行在虚拟化环境中，提供基础服务工具）
#
# 所有输出在 outputs/default.nix 中组装，模块化设计便于按需增删应用。
# =============================================================================
{
  description = "Misty 的 NixOS 配置 — 桌面（Niri/Hyprland）+ 服务器";

  # ---------------------------------------------------------------------------
  # nixConfig 仅影响 flake 自身的构建行为，不影响系统配置
  # 国内用户可添加镜像加速二进制缓存下载
  # ---------------------------------------------------------------------------
  nixConfig = {
    extra-substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
  };

  # ---------------------------------------------------------------------------
  # inputs — flake 的依赖项
  # 每项都会作为参数传递给 outputs 函数
  # ---------------------------------------------------------------------------
  inputs = {
    # 官方 NixOS 包源，默认使用 unstable 分支
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # 稳定分支，用于需要稳定性的包
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    # home-manager — 用户环境管理，与 NixOS 配合管理用户级配置
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # follows 使 home-manager 使用与本 flake 相同的 nixpkgs，避免版本不一致
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # catppuccin — 主题配色方案
    catppuccin = {
      url = "github:catppuccin/nix/v26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # noctalia — 原生 Wayland 桌面 shell（Niri 分支使用）
    # 基于 Wayland + OpenGL ES，非 Qt/Gtk，原生支持 Niri 工作区集成
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland — 动态平铺 Wayland 合成器（Hyprland 分支使用）
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # disko — 声明式磁盘分区管理
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix — 声明式密钥管理（通过 sops 加密 YAML 文件管理密码、密钥等）
    # 密钥以加密形式存储在仓库中，构建时通过 age/GPG 解密
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # ---------------------------------------------------------------------------
  # outputs — flake 的输出，委托给 outputs/default.nix 组装
  # ---------------------------------------------------------------------------
  outputs = inputs: import ./outputs inputs;
}
