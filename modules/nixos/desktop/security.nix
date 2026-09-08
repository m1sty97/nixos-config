# =============================================================================
# modules/nixos/desktop/security.nix — 桌面安全配置
# -----------------------------------------------------------------------------
# polkit 权限管理、GNOME Keyring 密钥环、SSH Agent、GnuPG Agent。
# =============================================================================
{
  config,
  pkgs,
  ...
}:
{
  # polkit — 权限认证代理
  security.polkit.enable = true;

  # GNOME Keyring — 密钥环，存储密码和密钥
  services.gnome = {
    gnome-keyring.enable = true;
    # 禁用 gcr-ssh-agent，使用 OpenSSH 自带的 ssh-agent
    gcr-ssh-agent.enable = false;
  };

  # Seahorse — GNOME Keyring 的 GUI 管理工具
  programs.seahorse.enable = true;

  # OpenSSH Agent — 记住 SSH 私钥密码短语
  programs.ssh.startAgent = true;

  # greetd 登录时自动解锁 GNOME Keyring
  security.pam.services.greetd.enableGnomeKeyring = true;
  # passwd 修改密码时同步更新 Keyring 密码
  security.pam.services.passwd.enableGnomeKeyring = true;

  # GnuPG Agent — GPG 密钥管理
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt; # Qt 图形界面的密码输入框
    enableSSHSupport = false;
    settings.default-cache-ttl = 4 * 60 * 60; # 缓存 4 小时
  };
}
