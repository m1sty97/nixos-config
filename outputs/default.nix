# =============================================================================
# outputs/default.nix — Flake 输出组装
# -----------------------------------------------------------------------------
# 将所有 NixOS 主机配置组装为 flake 的 nixosConfigurations 输出。
# 这是 flake.nix 的 outputs 函数委托的入口。
#
# flake.nix 中 outputs = inputs: import ./outputs inputs;
# 传入的 inputs 是一个包含 self/nixpkgs/home-manager 等所有 flake input 的属性集。
# 此处用 @inputs' 绑定整个属性集，同时解构需要的个别键。
# =============================================================================
{
  self,
  nixpkgs,
  ...
}@inputs':
let
  inherit (inputs'.nixpkgs) lib;

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

      # 将完整的 flake inputs 属性集传入，供模块中引用
      # 如 inputs.hyprland.nixosModules.default、inputs.sops-nix.nixosModules.sops
      inputs = inputs';

      # 稳定版 nixpkgs 实例（用于需要稳定性的包）
      pkgs-stable = import inputs'.nixpkgs-stable {
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
    # 桌面主机 — misty-desktop
    # 同时安装 Niri 与 Hyprland，登录时通过 tuigreet 选择会话切换
    # 部署命令：sudo nixos-rebuild switch --flake .#misty-desktop
    # =========================================================================
    misty-desktop = mylib.nixosSystem {
      inherit lib system myvars genSpecialArgs;

      # NixOS 系统级模块
      nixos-modules = [
        # 桌面环境入口（自动导入 base + desktop 模块，含 greetd 登录管理器）
        ../modules/nixos/desktop.nix
        # Hyprland 系统级模块（启用与否由主机配置中的选项控制）
        ../modules/nixos/hyprland.nix
        # 主机特定配置
        ../hosts/misty-desktop
      ];

      # home-manager 用户级模块
      home-modules = [
        # 桌面主机的完整 GUI 用户配置（Niri + Hyprland + Noctalia）
        ../home/hosts/linux/misty-desktop.nix
      ];
    };

    # =========================================================================
    # 服务器主机 — misty-server
    # 运行在虚拟化环境中的服务器，提供基础服务工具
    # 部署命令：sudo nixos-rebuild switch --flake .#misty-server
    # =========================================================================
    misty-server = mylib.nixosSystem {
      inherit lib system myvars genSpecialArgs;

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
      # sops 密钥管理工具
      sops
      # age 加密工具（sops 的默认加密后端）
      age
    ];
    name = "nixos-config-dev";
  };

  # ---------------------------------------------------------------------------
  # 格式化器
  # ---------------------------------------------------------------------------
  formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;
}
