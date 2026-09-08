# =============================================================================
# lib/default.nix — 自定义辅助函数库
# -----------------------------------------------------------------------------
# 提供在所有 NixOS / home-manager 模块中复用的辅助函数。
# =============================================================================
{ lib, ... }:
{
  # ---------------------------------------------------------------------------
  # nixosSystem — 组装 NixOS 系统配置，集成 home-manager
  # 参数说明：
  #   nixos-modules  — NixOS 系统级模块列表
  #   home-modules   — home-manager 用户级模块列表（可选）
  #   system         — 目标架构，如 "x86_64-linux"
  #   specialArgs    — 传递给所有模块的特殊参数（自动生成）
  # ---------------------------------------------------------------------------
  nixosSystem = import ./nixosSystem.nix;

  # ---------------------------------------------------------------------------
  # relativeToRoot — 将相对路径转换为相对于 flake 根目录的绝对路径
  # 用法：mylib.relativeToRoot "modules/nixos/base"
  # ---------------------------------------------------------------------------
  relativeToRoot = lib.path.append ../.;

  # ---------------------------------------------------------------------------
  # scanPaths — 自动扫描目录下的所有 .nix 文件和子目录
  # 忽略 default.nix，自动导入其余模块
  # 用法：imports = mylib.scanPaths ./.;
  # ---------------------------------------------------------------------------
  scanPaths =
    path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
          (_type == "directory") # 包含子目录
          || (
            (path != "default.nix") # 忽略 default.nix
            && (lib.strings.hasSuffix ".nix" path) # 包含 .nix 文件
          )
        ) (builtins.readDir path)
      )
    );
}
