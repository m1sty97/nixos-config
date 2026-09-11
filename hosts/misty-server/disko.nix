# =============================================================================
# hosts/misty-server/disko.nix — 磁盘分区声明（disko）
# -----------------------------------------------------------------------------
# 由 disko 声明式管理服务器虚拟机的磁盘布局：
#   GPT：ESP(512M, 挂载 /boot) + swap(4G) + 根分区(其余空间, 挂载 /)
# 服务器以 UEFI + GRUB2 引导（与桌面主机一致，见 base/core.nix），
# 因此需要 EF00 类型的 EFI 系统分区挂载为 /boot。
#
# 装机命令（⚠️ 会清空目标磁盘上的全部数据）：
#   sudo nix run github:nix-community/disko -- \
#     --mode destroy,format,mount hosts/misty-server/disko.nix
# =============================================================================
{ ... }:
let
  # virtio 磁盘设备名；装机前用 lsblk 确认
  diskDevice = "/dev/vda";
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

        # 交换分区
        swap = {
          size = "4G";
          content.type = "swap";
        };

        # 根分区（ext4）
        root = {
          size = "100%";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };
  };
}
