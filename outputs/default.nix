# =============================================================================
# outputs/default.nix — Flake 输出组装
# -----------------------------------------------------------------------------
# 将所有 NixOS 主机配置组装为 flake 的 nixosConfigurations 输出。
# 这是 flake.nix 的 outputs 函数委托的入口。
# =============================================================================
{
  self,
  nixpkgs,
  inputs,
  ...
}@inputs':
let
  inherit (inputs.nixpkgs) lib;

  # ---------------------------------------------------------------------------
  # mylib — 自定义辅助函数库
  # ---------------------------------------------------------------------------
  mylib = import ../lib { inherit lib; };

  # ---------------------------------------------------------------------------
  # myvars — 全局变量
  # ---------------------------------------------------------------------------
  myvars = import ../vars { inherit lib; };

  # ---------------------------------------------------------------------------
  # genSpecialArgs — 为每个系统架构生成 specialArgs
  # specialArgs 会传递给所有 NixOS 和 home-manager 模块，
  # 使它们可以使用 inputs, mylib, myvars 等。
  # ---------------------------------------------------------------------------
  genSpecialArgs =
    system:
    inputs'
    // {
      inherit mylib myvars;

      # 稳定版 nixpkgs 实例（用于需要稳定性的包）
      pkgs-stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
    };

  # ---------------------------------------------------------------------------
  # 系统架构
  # ---------------------------------------------------------------------------
  system = "x86_64-linux";
in
{
  # ---------------------------------------------------------------------------
  # NixOS 主机配置
  # ---------------------------------------------------------------------------
  nixosConfigurations = {
    # =========================================================================
    # 桌面主机 — misty-desktop（Niri 分支）
    # Niri + Noctalia Shell 日常使用桌面
    # 部署命令：sudo nixos-rebuild switch --flake .#misty-desktop
    # =========================================================================
    misty-desktop = mylib.nixosSystem {
      inherit system myvars genSpecialArgs;

      # NixOS 系统级模块
      nixos-modules = [
        # 桌面环境入口（自动导入 base + desktop 模块）
        ../modules/nixos/desktop.nix
        # 主机特定配置
        ../hosts/misty-desktop
      ];

      # home-manager 用户级模块
      home-modules = [
        # 桌面主机的完整 GUI 用户配置
        ../home/hosts/linux/misty-desktop.nix
      ];
    };

    # =========================================================================
    # 桌面主机 — misty-hyprland（Hyprland 分支）
    # Hyprland + dots-hyprland (illogical-impulse) 桌面
    # 部署命令：sudo nixos-rebuild switch --flake .#misty-hyprland
    # =========================================================================
    misty-hyprland = mylib.nixosSystem {
      inherit system myvars genSpecialArgs;

      # NixOS 系统级模块
      nixos-modules = [
        # 桌面环境入口（自动导入 base + desktop 模块）
        ../modules/nixos/desktop.nix
        # Hyprland 系统级模块
        ../modules/nixos/hyprland.nix
        # 主机特定配置
        ../hosts/misty-hyprland
      ];

      # home-manager 用户级模块
      home-modules = [
        ../home/hosts/linux/misty-hyprland.nix
      ];
    };

    # =========================================================================
    # 服务器主机 — misty-server
    # 运行在虚拟化环境中的服务器，提供基础服务工具
    # 部署命令：sudo nixos-rebuild switch --flake .#misty-server
    # =========================================================================
    misty-server = mylib.nixosSystem {
      inherit system myvars genSpecialArgs;

      # NixOS 系统级模块
      nixos-modules = [
        # 服务器基础模块（自动导入 base + virtualisation 客户机配置）
        ../modules/nixos/server/default.nix
        # 主机特定配置
        ../hosts/misty-server
      ];

      # home-manager 用户级模块（仅 CLI，无 GUI）
      home-modules = [
        ../home/hosts/linux/misty-server.nix
      ];
    };
  };

  # ---------------------------------------------------------------------------
  # 开发环境
  # ---------------------------------------------------------------------------
  devShells.${system}.default = let
    pkgs = nixpkgs.legacyPackages.${system};
  in pkgs.mkShell {
    packages = with pkgs; [
      # Nix 格式化工具
      nixfmt
      # 死代码检测
      deadnix
      # Nix linter
      statix
    ];
    name = "nixos-config-dev";
  };

  # ---------------------------------------------------------------------------
  # 格式化器
  # ---------------------------------------------------------------------------
  formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;
}
