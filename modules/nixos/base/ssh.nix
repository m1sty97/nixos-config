# =============================================================================
# modules/nixos/base/ssh.nix — SSH 服务基础配置
# -----------------------------------------------------------------------------
# 安全默认值：防火墙默认开启、禁用密码登录、禁用 X11 转发（桌面可覆盖）。
# =============================================================================
{ lib, ... }:
{
  # 防火墙默认开启（服务器主机可在各自配置中关闭）
  networking.firewall.enable = lib.mkDefault true;

  # OpenSSH 服务
  services.openssh = {
    enable = true;
    settings = {
      # 默认禁止 X11 转发（桌面主机可在 desktop/ssh.nix 中开启）
      X11Forwarding = lib.mkDefault false;
      # 允许 root 用户通过密钥登录（用于远程部署）
      PermitRootLogin = lib.mkDefault "prohibit-password";
      # 禁止密码登录，仅允许密钥认证
      PasswordAuthentication = false;
      # 公钥来源：用户 ~/.ssh/authorized_keys、users 模块生成的
      # /etc/ssh/authorized_keys.d/%u，以及 sops 解密出的公钥文件
      # （sshd 认证时以 root 读取，因此运行时路径可行）
      AuthorizedKeysFile = [
        ".ssh/authorized_keys"
        ".ssh/authorized_keys2"
        "/etc/ssh/authorized_keys.d/%u"
        "/run/secrets/ssh/authorized_keys"
      ];
    };
    openFirewall = true;
  };

  # 安装所有已知终端的 terminfo 数据库
  environment.enableAllTerminfo = true;
}
