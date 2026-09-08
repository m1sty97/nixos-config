# =============================================================================
# modules/nixos/desktop/virtualisation.nix — 桌面虚拟化配置
# -----------------------------------------------------------------------------
# 桌面主机上的容器和虚拟化支持：Podman（替代 Docker）、QEMU/KVM。
# 服务器级别的完整虚拟化在 server/virtualisation.nix 中配置。
# =============================================================================
{ pkgs, ... }:
{
  # VFIO PCI 模块（用于 GPU 直通等场景）
  boot.kernelModules = [ "vfio-pci" ];

  # Flatpak 支持桌面安装的扁平化包管理
  services.flatpak.enable = true;

  virtualisation = {
    # 禁用 Docker（使用 Podman 替代）
    docker.enable = false;

    # Podman — 无守护进程的容器引擎，兼容 Docker CLI
    podman = {
      enable = true;
      # 创建 docker 别名，可作为 Docker 的直接替代品
      dockerCompat = true;
      # podman-compose 容器间通信需要 DNS
      defaultNetwork.settings.dns_enabled = true;
      # 每周自动清理 Podman 资源
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = [ "--all" ];
      };
    };

    # OCI 容器后端使用 Podman
    oci-containers.backend = "podman";
  };

  environment.systemPackages = with pkgs; [
    # QEMU/KVM 主机虚拟化工具
    qemu_kvm

    # QEMU 全架构模拟（支持 ARM、RISC-V 等）
    qemu
  ];
}
