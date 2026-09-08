# =============================================================================
# modules/nixos/base/users.nix — 用户配置
# -----------------------------------------------------------------------------
# 创建默认用户 misty，配置 SSH 公钥和用户组。
# =============================================================================
{ myvars, ... }:
{
  # SSH 客户端配置（主机别名等）
  programs.ssh = myvars.networking.ssh;

  users.users.${myvars.username} = {
    description = myvars.userfullname;

    # 初始密码哈希（首次登录后请用 passwd 修改）
    initialHashedPassword = myvars.initialHashedPassword;

    # 可登录的 SSH 公钥
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
