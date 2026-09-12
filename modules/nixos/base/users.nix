# =============================================================================
# modules/nixos/base/users.nix — 用户配置
# -----------------------------------------------------------------------------
# 创建默认用户 misty，配置 SSH 公钥和用户组。
# 用户密码哈希通过 sops-nix 从加密文件中读取（见 sops.nix）。
# =============================================================================
{
  myvars,
  config,
  lib,
  ...
}:
{
  # SSH 客户端配置（主机别名等）
  programs.ssh = myvars.networking.ssh;

  users.users.${myvars.username} = {
    description = myvars.userfullname;

    # ---------------------------------------------------------------------------
    # 用户密码哈希 — 从 sops 解密文件读取（/run/secrets/misty/hashed_password）
    # ---------------------------------------------------------------------------
    hashedPasswordFile = config.sops.secrets."misty/hashed_password".path;

    # ---------------------------------------------------------------------------
    # 可登录的 SSH 公钥
    # keys  — vars 中的静态配置（回退）
    # files — sops 解密出的公钥文件，由 sshd 运行时读取（实际生效来源）
    # ---------------------------------------------------------------------------
    openssh.authorizedKeys = {
      keys = myvars.mainSshAuthorizedKeys;
      files = [ config.sops.secrets."ssh/authorized_keys".path ];
    };

    # 加入以下用户组：
    # - wheel      — sudo 提权
    # - networkmanager — 网络管理
    # - video      — 视频设备访问（亮度控制等）
    # - input      — 输入设备访问
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
    ];

    # 默认 shell 设为 zsh
    shell = "/run/current-system/sw/bin/zsh";
  };

  # 确保 zsh 在 /etc/shells 中
  programs.zsh.enable = true;

  # ---------------------------------------------------------------------------
  # 锁定 root 密码登录（"!" 为 shadow 锁定标记）
  # 物理控制台无法无密码进入 root；提权走 sudo，远程走 misty + SSH 密钥。
  # sshd 侧由 PermitRootLogin = "prohibit-password" 双重限制（见 ssh.nix）。
  # ---------------------------------------------------------------------------
  users.users.root.hashedPassword = lib.mkDefault "!";
}
