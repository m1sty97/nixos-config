# =============================================================================
# home/base/core/shells.nix — Shell 配置（zsh + starship）
# -----------------------------------------------------------------------------
# zsh 作为默认 shell，starship 作为跨 shell 的提示符。
# =============================================================================
{
  pkgs,
  config,
  ...
}:
let
  # Shell 别名
  shellAliases = {
    # 文件操作
    ll = "ls -la";
    la = "ls -A";
    l = "ls -CF";

    # Git 快捷命令
    gs = "git status";
    gd = "git diff";
    gc = "git commit";
    gp = "git push";
    gl = "git pull";

    # NixOS 快捷命令
    ns = "sudo nixos-rebuild switch --flake .#";
    nb = "sudo nixos-rebuild boot --flake .#";
    nt = "nixos-rebuild test --flake .#";
    ng = "nix-collect-garbage --delete-older-than 7d";

    # 目录跳转（配合 zoxide 使用 z 命令）
    ".." = "cd ..";
    "..." = "cd ../..";
  };
in
{
  # ---------------------------------------------------------------------------
  # Zsh — 默认 Shell
  # ---------------------------------------------------------------------------
  programs.zsh = {
    enable = true;

    # 自动补全
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # 历史记录配置
    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true; # 多终端共享历史
    };

    # Shell 别名
    inherit shellAliases;

    # .zshrc 额外配置
    initContent = ''
      # 加载 ~/.local/bin 到 PATH
      export PATH="$PATH:$HOME/.local/bin"

      # 加载 cargo bin（Rust）
      export PATH="$PATH:$HOME/.cargo/bin"

      # 加载 go bin
      export PATH="$PATH:$HOME/go/bin"
    '';
  };

  # ---------------------------------------------------------------------------
  # Starship — 跨 Shell 的提示符
  # 参考：https://starship.rs/config/
  # ---------------------------------------------------------------------------
  programs.starship = {
    enable = true;

    # 在各 Shell 中启用集成
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = {
      # 配置 schema
      "$schema" = "https://starship.rs/config-schema.json";

      # 提示符字符
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      # 禁用不常用的模块
      aws.disabled = true;
      gcloud.disabled = true;

      # Kubernetes 模块（在服务器上管理 K8s 时有用）
      kubernetes = {
        symbol = "⛵";
        disabled = false;
      };

      # 显示操作系统图标
      os.disabled = false;
    };
  };
}
