# =============================================================================
# hosts/server-template/disko.nix — 磁盘分区声明模板（disko）
# -----------------------------------------------------------------------------
# 由 disko 声明式管理服务器磁盘布局：
#   GPT：ESP(512M, 挂载 /boot) + swap(8G) + btrfs(其余空间, 子卷 @/@home/@nix)
# UEFI + GRUB2 引导（与全部主机一致，见 base/core.nix）。
#
# 装机命令（⚠️ 会清空目标磁盘上的全部数据，install.sh 会自动执行）：
#   sudo nix run .#disko -- --mode destroy,format,mount hosts/<主机名>/disko.nix
# =============================================================================
{ ... }:
let
  # ⚠️ TODO: 装机前务必用 lsblk 确认实际磁盘设备名，并同步修改此处
  diskDevice = "/dev/sda";
in
{
  disko.devices.disk.main = {
    device = diskDevice;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        # EFI 系统分区（EF00），挂载为 /boot
        ESP = {
          size = "512M";
          type = "EF00";
          priority = 1;
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            # 仅 root 可读写 ESP
            mountOptions = [ "fmask=0077" "dmask=0077" ];
          };
        };

        # 交换分区（容量可按内存大小调整）
        swap = {
          size = "8G";
          content.type = "swap";
        };

        # btrfs 根分区，按子卷划分系统/用户数据/nix 存储
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            # 覆盖磁盘上已有的 btrfs 签名
            extraArgs = [ "-f" ];
            subvolumes = {
              "/@" = { mountpoint = "/"; };
              "/@home" = { mountpoint = "/home"; };
              "/@nix" = { mountpoint = "/nix"; };
            };
          };
        };
      };
    };
  };
}
