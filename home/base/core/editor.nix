# =============================================================================
# home/base/core/editor.nix — 默认编辑器配置（Vim + Helix 备用）
# -----------------------------------------------------------------------------
# 设置 vim 为默认编辑器，helix 作为现代备用编辑器。
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

  # ---------------------------------------------------------------------------
  # Helix — 现代模态编辑器（备用编辑器）
  # 参考：https://helix-editor.com/
  # 与 Vim 不同的是 Helix 内置了 LSP 支持、Tree-sitter 语法高亮和多选编辑，
  # 无需额外插件配置即可使用。
  # ---------------------------------------------------------------------------
  programs.helix = {
    enable = true;

    # 额外的语言言服务器
    extraPackages = with pkgs; [
      nixd # Nix 语言服务器
      marksman # Markdown 语言服务器
      python312Packages.python-lsp-server # Python 语言服务器
      typescript-language-server # TypeScript/JavaScript 语言服务器
    ];

    # Helix 配置
    settings = {
      # 主题
      theme = "catppuccin_macchiato";

      # 编辑器设置
      editor = {
        # 行号
        line-number = "relative";
        # 鼠标
        mouse = true;
        # 自动补全
        auto-completion = true;
        # 自动保存
        auto-save = false;
        # 自动格式化
        auto-format = true;
        # 弹出菜单
        popup-border = "all";

        # 光标
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        # 文件选择器
        file-picker = {
          hidden = false;
        };

        # 缩进指引线
        indent-guides = {
          render = true;
          character = "┊";
        };

        # LSP
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        # 状态栏
        statusline = {
          left = [
            "mode"
            "spinner"
            "file-name"
            "file-modification-indicator"
          ];
          right = [
            "diagnostics"
            "selections"
            "position"
            "file-encoding"
            "file-line-ending"
            "file-type"
          ];
        };
      };

      # 按键绑定
      keys = {
        normal = {
          # 快速跳转
          "space" = {
            "f" = "file_picker";
            "b" = "buffer_picker";
            "s" = "symbol_picker";
            "S" = "workspace_symbol_picker";
            "d" = "diagnostics";
            "g" = "goto_last_modification";
          };
        };
      };
    };

    # 语言配置
    languages = {
      # Nix 语言
      nix = {
        language-servers = [ "nixd" ];
        formatter.command = "nixfmt";
        auto-format = true;
      };

      # Python
      python = {
        language-servers = [ "pylsp" ];
        auto-format = true;
      };

      # TypeScript/JavaScript
      typescript = {
        language-servers = [ "typescript-language-server" ];
        auto-format = true;
      };
    };
  };
}
