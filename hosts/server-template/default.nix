# =============================================================================
# hosts/server-template/default.nix — 服务器主机模板
# -----------------------------------------------------------------------------
# ⚠️ 本目录是模板，未被 flake 注册，不会被构建。新增服务器时：
#
#   1. 复制本目录为 hosts/<你的主机名>/（下同，复制后全局替换 TEMPLATE_HOST）
#   2. 修改本文件 hostName 与注释中的主机名
#   3. 修改 disko.nix 顶部的 diskDevice（装机前用 lsblk 确认）
#   4. vars/networking.nix 的 hostsAddr 增加该主机条目
#   5. 复制 home/hosts/linux/server-template.nix 为 <你的主机名>.nix
#   6. outputs/default.nix 注册 nixosConfigurations 条目
#      （复制文件末尾的注释示例，去掉注释即可）
#   7. 装机：sudo ./install.sh <你的主机名>
#
# 个性化配置直接在本文件的 imports / config 区追加；
# 通用 server 能力（qemu-guest、基础工具包）已由导入的模块提供。
# =============================================================================
{
  inputs,
  ...
}:
let
  hostName = "TEMPLATE_HOST"; # TODO: 改为实际主机名
in
{
  imports = [
    # 磁盘分区声明 — 由 disko 声明式管理，自动生成 fileSystems
    inputs.disko.nixosModules.default
    ./disko.nix

    # 硬件配置
    ./hardware-configuration.nix

    # QEMU 客户机配置（作为虚拟机运行时需要；物理机部署可移除）
    ../../modules/nixos/server/qemu-guest.nix
  ];

  # ---------------------------------------------------------------------------
  # 网络 — 使用 NetworkManager + DHCP（base 默认），此处仅设置主机名
  # ---------------------------------------------------------------------------
  networking.hostName = hostName;

  # ---------------------------------------------------------------------------
  # 系统状态版本（新主机一律使用当前版本，勿改动）
  # ---------------------------------------------------------------------------
  system.stateVersion = "26.05";
}
