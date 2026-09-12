# =============================================================================
# home/base/core/git.nix — Git 版本控制配置
# -----------------------------------------------------------------------------
# 全局 Git 配置、GitHub CLI、delta diff 查看器。
# =============================================================================
{
  config,
  lib,
  pkgs,
  myvars,
  ...
}:
{
  # 删除已有的 ~/.gitconfig（避免与 home-manager 冲突）
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    rm -f ${config.home.homeDirectory}/.gitconfig
  '';

  # GitHub CLI 工具
  home.packages = [ pkgs.gh ];

  # ---------------------------------------------------------------------------
  # Git 配置 — 生成 ~/.config/git/config
  # ---------------------------------------------------------------------------
  programs.git = {
    enable = true;
    lfs.enable = true; # Git LFS 大文件支持

    settings = {
      # 用户信息
      user.email = myvars.gituseremail;
      user.name = myvars.gitusername;

      # 初始分支名
      init.defaultBranch = "master";

      # 推送时自动设置上游
      push.autoSetupRemote = true;

      # 拉取时使用 rebase 而非 merge
      pull.rebase = true;

      # 日志日期格式
      log.date = "iso";

      # 别名
      alias = {
        br = "branch";
        co = "checkout";
        st = "status";
        ls = "log --pretty=format:'%C(yellow)%h%Cred%d %Creset%s%Cblue [%cn]' --decorate";
        ll = "log --pretty=format:'%C(yellow)%h%Cred%d %Creset%s%Cblue [%cn]' --decorate --numstat";
        cm = "commit -m";
        ca = "commit -am";
        dc = "diff --cached";
        unstage = "reset HEAD --";
        amend = "commit --amend -m";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Delta — 语法高亮的 diff 查看器
  # ---------------------------------------------------------------------------
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      line-numbers = true;
      true-color = "always";
    };
  };

  # Lazygit — Git 终端 UI
  programs.lazygit.enable = true;
}
