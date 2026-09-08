# ❄️ Misty 的 NixOS 配置

> 个人 NixOS 配置，基于 Flakes + home-manager，模块化设计。
> 包含 Niri 和 Hyprland 两个桌面配置分支，以及一个服务器主机配置。

## 📋 组件概览

| 组件 | Niri 桌面 | Hyprland 桌面 | 服务器主机 |
|------|----------|---------------|------------|
| **窗口管理器** | [Niri](https://github.com/YaLTeR/niri)（scrollable-tiling） | [Hyprland](https://hyprland.org/)（dynamic tiling） | 无 |
| **桌面 Shell** | [Noctalia](https://github.com/noctalia-dev/noctalia)（原生 Wayland） | dots-hyprland (illogical-impulse quickshell) | 无 |
| **Shell** | zsh + starship | zsh + starship | zsh + starship |
| **编辑器** | vim（主）+ helix（备用） | vim + helix | vim |
| **终端** | Ghostty（GPU 加速） | Ghostty | 无 |
| **输入法** | fcitx5 + rime | fcitx5 + rime | 无 |
| **主题** | Catppuccin Macchiato | Catppuccin / Material You | — |
| **容器** | Podman + Flatpak | Podman + Flatpak | Podman |
| **网络** | NetworkManager | NetworkManager | systemd-networkd（静态 IP） |
| **登录管理** | greetd + tuigreet | greetd + tuigreet | SSH |

### 三个主机配置

| 主机名 | Flake 输出 | 说明 |
|--------|-----------|------|
| `misty-desktop` | `.#misty-desktop` | Niri + Noctalia 日常桌面 |
| `misty-hyprland` | `.#misty-hyprland` | Hyprland + dots-hyprland 桌面 |
| `misty-server` | `.#misty-server` | 运行在虚拟化环境中的服务器 |

## 📁 目录结构

```
nixos-config/
├── flake.nix                    # Flake 入口（nixpkgs/home-manager/catppuccin/noctalia/hyprland/disko）
├── lib/                         # 辅助函数库（scanPaths / nixosSystem）
├── vars/                        # 全局变量（用户名/网络/SSH）
│
├── modules/nixos/               # 系统级模块
│   ├── desktop.nix              #   桌面入口（Wayland/greetd）
│   ├── hyprland.nix             #   Hyprland 系统级模块
│   ├── base/                    #   通用基础（所有主机）
│   ├── desktop/                 #   桌面专属（fonts/security/virtualisation）
│   └── server/                  #   服务器专属
│       ├── default.nix          #     服务器基础（导入 base + virtualisation）
│       ├── qemu-guest.nix       #     QEMU 客户机配置
│       └── virtualisation.nix   #     虚拟化客户机工具（Podman + 服务器基础工具）
│
├── home/                        # 用户级模块（home-manager）
│   ├── base/                    #   跨平台用户配置
│   │   ├── core/                #     核心配置
│   │   │   ├── shells.nix       #       zsh + starship
│   │   │   ├── editor.nix       #       vim + helix
│   │   │   ├── git.nix          #       git + delta + lazygit
│   │   │   └── tools.nix        #       eza/bat/fzf/zoxide/btop/yazi
│   │   └── gui/                 #     GUI 配置
│   │       ├── terminal.nix     #       Ghostty 终端
│   │       ├── browsers.nix     #       Firefox + Chrome
│   │       └── media.nix        #       mpv/pavucontrol/imv
│   ├── linux/gui/
│   │   ├── niri.nix             #       Niri WM（条件启用）
│   │   ├── niri/conf/           #       Niri KDL 配置文件
│   │   ├── noctalia.nix         #       Noctalia Shell（Niri 分支）
│   │   ├── hyprland.nix         #       Hyprland WM（条件启用）
│   │   └── fcitx5.nix           #       中文输入法
│   └── hosts/linux/             #   主机专属 home 入口
│       ├── misty-desktop.nix    #     Niri 桌面（启用 niri）
│       ├── misty-hyprland.nix   #     Hyprland 桌面（启用 hyprland）
│       └── misty-server.nix     #     服务器（仅 CLI）
│
├── hosts/                       # 主机系统级配置
│   ├── misty-desktop/           #   Niri 桌面
│   ├── misty-hyprland/          #   Hyprland 桌面
│   └── misty-server/            #   服务器
│
└── outputs/
    └── default.nix              # 组装 3 个 nixosConfigurations
```

## 🚀 快速开始

### 1. 首次安装（从 NixOS ISO）

```bash
# 1. 从 NixOS 官方 ISO 启动 → https://nixos.org/download

# 2. 克隆配置仓库
git clone <你的仓库地址> ~/nixos-config
cd ~/nixos-config

# 3. 生成硬件配置
sudo nixos-generate-config --show-hardware-config > hosts/misty-desktop/hardware-configuration.nix

# 4. 编辑 vars/default.nix，修改：
#    - initialHashedPassword（用 `mkpasswd -m yescrypt` 生成）
#    - mainSshAuthorizedKeys（你的 SSH 公钥）
#    - useremail

# 5. 编辑 vars/networking.nix，修改网络配置

# 6. 安装 NixOS
sudo nixos-install --root /mnt --flake .#misty-desktop --no-root-password

# 7. 重启
reboot
```

### 2. Hyprland 分支额外步骤

Hyprland 分支使用 dots-hyprland (illogical-impulse) 的配置文件，需要额外克隆：

```bash
# 克隆 dots-hyprland 仓库并初始化子模块（quickshell 圆角组件等）
git clone --recurse-submodules https://github.com/clsty/illogical-impulse.git ~/dots-hyprland

# 如果已克隆但未初始化子模块：
cd ~/dots-hyprland && git submodule update --init
```

配置文件通过符号链接从 `~/dots-hyprland/dots/.config/` 链接到 `~/.config/`：
- `hypr/` — Hyprland Lua DSL 配置（hyprland.lua 入口 + hyprland/ + custom/）
- `quickshell/` — illogical-impulse Quickshell UI shell（bar/lock/overview/sidebar 等）
- `custom/` — 用户自定义覆盖目录，保持可写（修改 Hyprland 配置在此处进行）

matugen 主题系统会在运行时生成颜色到 `~/.local/state/quickshell/user/generated/`，该目录首次启动时自动创建。

### 3. 日常部署

```bash
cd ~/nixos-config

# Niri 桌面
sudo nixos-rebuild switch --flake .#misty-desktop

# Hyprland 桌面
sudo nixos-rebuild switch --flake .#misty-hyprland

# 服务器
sudo nixos-rebuild switch --flake .#misty-server

# 仅设置下次启动配置
sudo nixos-rebuild boot --flake .#misty-desktop

# 测试配置（重启后恢复）
nixos-rebuild test --flake .#misty-desktop

# 远程部署到服务器
sudo nixos-rebuild switch --flake .#misty-server --target-host misty-server
```

### 4. 常用维护命令

```bash
nix flake update                    # 更新所有 inputs
nix flake update nixpkgs            # 更新特定 input
nix profile history --profile /nix/var/nix/profiles/system  # 查看历史
sudo nix-collect-garbage --delete-older-than 7d  # 垃圾回收
nix fmt                             # 格式化 Nix 代码
nix develop                         # 进入开发环境
```

## ⌨️ Niri 快捷键速查

> `Mod` = `Super` 键

| 快捷键 | 功能 |
|--------|------|
| `Mod + T` | 打开终端 (Ghostty) |
| `Mod + W` | 打开浏览器 (Firefox) |
| `Mod + E` | 打开文件管理器 (Thunar) |
| `Mod + Q` | 关闭窗口 |
| `Mod + F` | 最大化列 |
| `Mod + 1~0` | 切换工作区 |
| `Mod + Shift + 1~0` | 移动窗口到工作区 |
| `Mod + L` | 锁屏 |
| `Mod + Shift + E` | 注销/电源菜单 |
| `Print` | 截图 |
| `Mod + Shift + R` | 重启 Noctalia Shell |

## 🖥️ Noctalia Shell 配置

- 配置文件：`home/linux/gui/noctalia.nix`（通过 `programs.noctalia.settings` 以 Nix attrset 写入 TOML）
- 运行时也可通过 Noctalia 的设置 GUI 修改
- IPC 控制：`noctalia msg --help`
- 原生支持 Niri 工作区集成（通过 ext-workspace-v1 协议）

## 🖥️ Hyprland 分支配置

- 配置文件来源：`~/dots-hyprland/dots/.config/`（通过 `xdg.configFile` 符号链接）
- 配置格式：Lua（hyprland.lua + hyprland/ 目录 + custom/ 覆盖）
- 桌面 Shell：dots-hyprland 的 quickshell 配置（illogical-impulse shell）
- 自定义修改：编辑 `~/dots-hyprland/dots/.config/hypr/custom/` 下的文件

## 🔧 如何增删应用

### 安装新应用（用户级）

在 `home/base/core/` 或 `home/base/gui/` 下创建 `.nix` 文件：

```nix
# home/base/gui/my-app.nix
{ pkgs, ... }:
{
  home.packages = with pkgs; [ discord obs-studio ];
}
```

文件会被 `scanPaths` 自动导入，无需修改 `default.nix`。

### 仅在特定 WM 分支安装

在 `home/hosts/linux/misty-desktop.nix` 或 `misty-hyprland.nix` 中添加：

```nix
{ pkgs, ... }:
{
  imports = [ ../../linux/gui.nix ];
  modules.desktop.niri.enable = true;  # 或 hyprland

  home.packages = with pkgs; [ steam ];
}
```

## ⚠️ 注意事项

1. **首次使用前必须修改**：
   - `vars/default.nix` 中的密码哈希、SSH 公钥、邮箱
   - `vars/networking.nix` 中的网络配置
   - `hosts/*/hardware-configuration.nix`（用 `nixos-generate-config` 生成）

2. **Hyprland 分支需要 dots-hyprland**：
   - 克隆 dots-hyprland 到 `~/dots-hyprland`
   - 配置通过符号链接引用，修改 dots-hyprland 中的文件即可

3. **Noctalia vs Caelestia Shell**：
   - 本配置已从 caelestia-shell 迁移到 Noctalia
   - Noctalia 原生支持 Niri（工作区集成通过 ext-workspace-v1）
   - Caelestia Shell 深度依赖 Hyprland IPC，在 Niri 下仅部分功能可用

4. **服务器主机**：
   - 服务器配置为运行在虚拟化环境中的客户机（非提供虚拟化服务）
   - 默认导入 `qemu-guest.nix`（QEMU 客户机支持）
   - 提供 Podman 容器运行时和基础服务器工具（tmux/rsync/jq/tcpdump 等）
   - 便于后续部署各种容器化服务

5. **国内镜像加速**：
   - `flake.nix` 中已配置 USTC 镜像

## 📚 参考资料

- [NixOS & Nix Flakes Book](https://github.com/ryan4yin/nixos-and-flakes-book)
- [Niri 配置文档](https://yalter.github.io/niri/)
- [Noctalia 文档](https://docs.noctalia.dev/noctalia/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [dots-hyprland (illogical-impulse)](https://github.com/clsty/illogical-impulse)
- [Home Manager](https://nix-community.github.io/home-manager/)

## 📄 许可证

MIT
