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
    # 文件操作（eza 替代 ls，包在 tools.nix 中安装）
    ls = "eza --icons";
    ll = "eza -l --icons --git";
    la = "eza -a --icons";
    lt = "eza --tree --icons";
    lla = "eza -la --icons --git";

    # Git 快捷命令（g 前缀 + 子命令全拼）
    gstatus = "git status";
    gadd = "git add";
    gdiff = "git diff";
    gcommit = "git commit";
    gpush = "git push";
    gpull = "git pull";
    glog = "git log --oneline --graph --decorate";

    # NixOS 快捷命令（rebuild + 子命令）
    rebuild = "sudo nixos-rebuild switch --flake .#";
    rebuild-boot = "sudo nixos-rebuild boot --flake .#";
    rebuild-test = "nixos-rebuild test --flake .#";
    nclean = "sudo nix-collect-garbage --delete-older-than 7d";

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

    # 命令补全、历史命令灰色建议、语法高亮
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      # 先按历史记录、再按补全匹配生成建议
      strategy = [ "history" "completion" ];
    };
    syntaxHighlighting.enable = true;

    # 历史记录配置
    history = {
      size = 10000;
      save = 10000;
      append = true; # 追加写入而非覆盖历史文件
      ignoreDups = true;
      ignoreSpace = true;
      share = true; # 多终端共享历史
      extended = true; # 记录命令执行时间与耗时
    };

    # Shell 别名
    inherit shellAliases;

    # .zshrc 额外配置
    initContent = ''
      # Tab 补全菜单：方向键在候选项间选择
      zstyle ':completion:*' menu select

      # 输入目录名即可跳转（无需 cd）
      setopt auto_cd

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
