# =============================================================================
# lib/nixosSystem.nix — NixOS 系统配置组装函数
# -----------------------------------------------------------------------------
# 将 NixOS 模块和 home-manager 模块组装为完整的 nixosSystem 配置。
# 参考 ryan4yin/nix-config 的设计，简化后用于个人配置。
# =============================================================================
{
  inputs,
  lib,
  system,
  genSpecialArgs,
  nixos-modules,
  home-modules ? [ ],
  specialArgs ? (genSpecialArgs system),
  myvars,
  ...
}:
let
  inherit (inputs) nixpkgs home-manager;
in
nixpkgs.lib.nixosSystem {
  inherit system specialArgs;
  modules =
    nixos-modules
    ++ (lib.optionals ((lib.lists.length home-modules) > 0) [
      # -----------------------------------------------------------------
      # home-manager 集成
      # 当提供了 home-modules 时，自动注入 home-manager 的 NixOS 模块
      # -----------------------------------------------------------------
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true; # 使用系统级 nixpkgs，避免重复实例
        home-manager.useUserPackages = true; # 用户包安装到 profile
        home-manager.backupFileExtension = "home-manager.backup"; # 冲突时备份旧文件

        # 将 specialArgs 传递给 home-manager 模块
        home-manager.extraSpecialArgs = specialArgs;

        # 为默认用户加载 home-modules
        home-manager.users."${myvars.username}".imports = home-modules;
      }
    ]);
}
