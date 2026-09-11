# =============================================================================
# hosts/misty-server/disko.nix — 磁盘分区声明（disko）
# -----------------------------------------------------------------------------
# 由 disko 声明式管理服务器虚拟机的磁盘布局：
#   GPT：BIOS boot(1M, GRUB 引导用) + swap(4G) + ext4(其余空间, 挂载 /)
# 服务器作为 QEMU/KVM 虚拟机运行，通过 GRUB/BIOS 引导（见 qemu-guest.nix），
# 因此无需 ESP，但需要 EF02 类型的 BIOS 引导分区供 GRUB 嵌入。
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
        # BIOS 引导分区（EF02）— GRUB 在 GPT 磁盘上需要 1M 嵌入空间
        biosboot = {
          size = "1M";
          type = "EF02";
          priority = 1;
        };

        # 交换分区
        swap = {
          size = "4G";
          content.type = "swap";
        };

        # 根分区（ext4，服务器布局保持简单）
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
