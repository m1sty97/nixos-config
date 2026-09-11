# =============================================================================
# home/base/core/editor.nix — 默认编辑器配置（Vim）
# -----------------------------------------------------------------------------
# 设置 vim 为默认编辑器（所有主机通用）。
# 桌面主机的图形编辑器（VS Code）见 home/base/gui/vscode.nix。
# =============================================================================
{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # 环境变量 — 设置默认编辑器为 vim
  # ---------------------------------------------------------------------------
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
    SUDO_EDITOR = "vim";
  };

  # ---------------------------------------------------------------------------
  # Vim 配置
  # ---------------------------------------------------------------------------
  programs.vim = {
    enable = true;

    # Vim 插件
    plugins = with pkgs.vimPlugins; [
      # 语法高亮
      vim-nix # Nix 语法支持
      vim-markdown # Markdown 支持

      # 配色方案
      catppuccin-vim # Catppuccin 主题

      # 文件浏览
      nerdtree # 文件树

      # 搜索
      fzf-vim # 模糊搜索集成

      # Git
      vim-fugitive # Git 集成

      # 状态栏
      lightline-vim # 轻量状态栏
    ];

    # Vim 额外配置
    extraConfig = ''
      " 基础设置
      set nocompatible
      syntax on
      filetype plugin indent on

      " 显示设置
      set number          " 显示行号
      set relativenumber  " 相对行号
      set cursorline      " 高亮当前行
      set showmatch       " 高亮匹配括号
      set showcmd         " 显示命令

      " 编辑设置
      set tabstop=4       " Tab 显示宽度
      set shiftwidth=4    " 自动缩进宽度
      set expandtab       " Tab 转空格
      set autoindent      " 自动缩进
      set smartindent     " 智能缩进

      " 搜索设置
      set incsearch       " 增量搜索
      set hlsearch        " 高亮搜索结果
      set ignorecase      " 忽略大小写
      set smartcase       " 智能大小写

      " 编码设置
      set encoding=utf-8
      set fileencoding=utf-8

      " 配色方案
      colorscheme catppuccin_macchiato

      " NERDTree 快捷键
      map <C-n> :NERDTreeToggle<CR>

      " 状态栏
      let g:lightline = { 'colorscheme': 'catppuccin_macchiato' }
    '';
  };
}
