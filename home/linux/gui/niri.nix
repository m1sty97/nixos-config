# =============================================================================
# home/linux/gui/niri.nix — Niri 窗口管理器配置
# -----------------------------------------------------------------------------
# Niri 是一个 scrollable-tiling Wayland 合成器。
# 参考：https://yalter.github.io/niri/
#
# 配置文件（KDL 格式）通过 xdg.configFile 链接到 ~/.config/niri/。
# 修改配置后用 `niri msg action --do-..." 或重新加载。
# =============================================================================
{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.modules.desktop.niri;
  # mkOutOfStoreSymlink 必须指向本机磁盘上的真实文件（而非 nix store），
  # 才能做到改配置不 rebuild 即生效。因此假定仓库按 README 安装步骤
  # clone 在 ~/nixos-config；若检出路径不同，请同步修改此处。
  confDir = "${config.home.homeDirectory}/nixos-config/home/linux/gui/niri/conf";
in
{
  # ---------------------------------------------------------------------------
  # 选项：是否启用 Niri
  # ---------------------------------------------------------------------------
  options.modules.desktop.niri = {
    enable = lib.mkEnableOption "Niri compositor";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # XWayland 兼容层（运行 X11 应用）
      xwayland-satellite

      # 截图标注（grim/slurp 由 desktop-tools.nix 统一安装）
      satty

      # polkit 认证代理（GUI 提权对话框）
      kdePackages.polkit-kde-agent-1
    ];

    # ---------------------------------------------------------------------------
    # Niri 配置文件 — 链接到 ~/.config/niri/
    # ---------------------------------------------------------------------------
    xdg.configFile = let
      mkSymlink = config.lib.file.mkOutOfStoreSymlink;
    in {
      "niri/config.kdl".source = mkSymlink "${confDir}/config.kdl";
      "niri/keybindings.kdl".source = mkSymlink "${confDir}/keybindings.kdl";
      "niri/spawn-at-startup.kdl".source = mkSymlink "${confDir}/spawn-at-startup.kdl";
      "niri/windowrules.kdl".source = mkSymlink "${confDir}/windowrules.kdl";
    };

    # ---------------------------------------------------------------------------
    # polkit 用户级 systemd 服务
    # ---------------------------------------------------------------------------
    systemd.user.services.niri-polkit = {
      Unit = {
        Description = "PolicyKit Authentication Agent for Niri";
        After = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
      };
      Install.WantedBy = [ "niri.service" ];
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

  };
}
