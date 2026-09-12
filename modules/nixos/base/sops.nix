# =============================================================================
# modules/nixos/base/sops.nix — sops-nix 声明式密钥管理
# -----------------------------------------------------------------------------
# 通过 sops-nix 管理用户密码哈希、SSH 公钥等敏感信息。
# 密钥以加密形式存储在 secrets/secrets.yaml 中，构建时自动解密。
#
# 前提条件：
#   1. 生成 age 密钥对：
#      nix shell nixpkgs#age --command age-keygen -o ~/.config/sops/age/keys.txt
#   2. 将公钥填入 .sops.yaml 的 creation_rules
#   3. 编辑加密密钥文件：
#      nix shell nixpkgs#sops --command sops secrets/secrets.yaml
#   4. 将 age 私钥部署到各主机的 /var/lib/sops-nix/age/keys.txt
#
# 解密后的密钥在运行时存储在 /run/secrets/ 中（tmpfs，重启后消失）
# =============================================================================
{
  inputs,
  config,
  lib,
  myvars,
  ...
}:
{
  # ---------------------------------------------------------------------------
  # 导入 sops-nix 的 NixOS 模块
  # ---------------------------------------------------------------------------
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  # ---------------------------------------------------------------------------
  # sops 配置
  # ---------------------------------------------------------------------------
  sops = {
    # 加密密钥文件路径（相对于 flake 根目录）
    defaultSopsFile = ../../secrets/secrets.yaml;

    # age 私钥路径 — 运行时用于解密
    # 部署时需将 age 私钥复制到此路径
    age = {
      # 私钥文件路径（各主机上需存在）
      keyFile = "/var/lib/sops-nix/age/keys.txt";

      # 构建时生成 age 密钥（首次部署时使用，生产环境建议手动部署私钥）
      # 如果设为 true，sops-nix 会在构建时自动生成 age 密钥对，
      # 但这要求构建环境能访问加密密钥——通常不推荐用于生产环境。
      # generateKey = false;
    };

    # ---------------------------------------------------------------------------
    # 密钥映射 — 将解密后的密钥值注入到系统配置中
    # ---------------------------------------------------------------------------
    secrets = {
      # 用户密码哈希 — 从 secrets.yaml 中的 misty.hashed_password 读取
      "misty/hashed_password" = {
        # sops-nix 会将解密后的值写入 /run/secrets/misty/hashed_password
        # 需要在用户配置中引用此路径
        neededForUsers = true; # 密码哈希必须在用户创建前可用
      };

      # SSH 公钥 — 从 secrets.yaml 中的 ssh.authorized_keys 读取
      # 值为多行字符串（每行一个公钥），由 sshd 认证时经
      # ssh.nix 的 AuthorizedKeysFile 读取
      "ssh/authorized_keys" = { };
    };
  };
}
