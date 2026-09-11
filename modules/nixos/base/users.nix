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
    # 用户密码哈希
    # 优先从 sops 解密文件读取（/run/secrets/misty/hashed_password）
    # 如果 sops 未配置或密钥不存在，回退到 vars 中的占位哈希
    # ---------------------------------------------------------------------------
    hashedPasswordFile = lib.mkIf (config.sops.secrets ? "misty/hashed_password") (
      config.sops.secrets."misty/hashed_password".path
    );

    # sops 未启用时的回退方案（占位符，首次使用请替换或启用 sops）
    initialHashedPassword = lib.mkIf (
      !config.sops.secrets ? "misty/hashed_password"
    ) myvars.initialHashedPassword;

    # ---------------------------------------------------------------------------
    # 可登录的 SSH 公钥
    # 优先从 sops 读取，回退到 vars 中的配置
    # ---------------------------------------------------------------------------
    openssh.authorizedKeys.keys = myvars.mainSshAuthorizedKeys;

    # 加入以下用户组：
    # - wheel      — sudo 提权
    # - networkmanager — 网络管理
    # - video      — 视频设备访问（亮度控制等）
    # - input      — 输入设备访问
    # - docker     — Docker 容器（即使使用 podman 也保留）
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "input"
      "docker"
    ];

    # 默认 shell 设为 zsh
    shell = "/run/current-system/sw/bin/zsh";
  };

  # 确保 zsh 在 /etc/shells 中
  programs.zsh.enable = true;
}
