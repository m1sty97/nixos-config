# =============================================================================
# modules/nixos/base/packages.nix — 基础系统级包
# -----------------------------------------------------------------------------
# 所有主机都需要的基础工具包。桌面/服务器特有的包在各自主模块中安装。
# =============================================================================
{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # 系统调用监控
    strace # 系统调用追踪
    lsof # 查看打开的文件

    # 系统监控
    sysstat
    lm_sensors # sensors 命令，查看温度
    pciutils # lspci
    usbutils # lsusb
    hdparm # 磁盘性能测试
    smartmontools # smartctl 磁盘健康检测
    nvme-cli # NVMe 磁盘工具

    # 基础工具
    psmisc # killall/pstree 等
    parted # 分区工具
    unzip # 解压 zip
    zip # 压缩 zip
    wget
    curl
    git
    vim # 默认编辑器

    # 密钥管理 CLI（编辑 secrets/secrets.yaml、手动加解密）
    # 注意：这只是命令行工具；激活时的自动解密由 sops-nix 模块负责
    sops
    age

    # 多语言开发工具链（AI 开发环境方案 docs/ai-dev-environment-design.md §5）
    # 工具链版本全局声明；项目内依赖由语言原生工具（pnpm/uv）管理
    nodejs_24 # Node.js LTS
    pnpm # Node 包管理器（registry 镜像在项目模板 shellHook 中声明）
    uv # Python 包/项目管理器
  ];

  # uv 系统级 PyPI 镜像（CERNET；项目内可用 UV_DEFAULT_INDEX 覆盖）
  environment.etc."uv/uv.toml".text = ''
    [[index]]
    url = "https://mirrors.cernet.edu.cn/pypi/simple"
    default = true
  '';
}
