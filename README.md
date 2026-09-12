# ❄️ Misty 的 NixOS 配置

> 个人 NixOS 配置，基于 Flakes + home-manager，模块化设计。
> 桌面主机同时安装 Niri 与 Hyprland（登录时可切换），外加一个服务器主机配置。

## 📋 组件概览

| 组件 | 桌面主机 | 服务器主机 |
|------|----------|------------|
| **窗口管理器** | [Niri](https://github.com/YaLTeR/niri)（scrollable-tiling）+ [Hyprland](https://hyprland.org/)（dynamic tiling），登录时切换 | 无 |
| **桌面 Shell** | [Noctalia](https://github.com/noctalia-dev/noctalia)（原生 Wayland，两个合成器共用） | 无 |
| **Shell** | zsh + starship | zsh + starship |
| **编辑器** | vim（终端，主）+ VS Code（图形） | vim |
| **浏览器** | Chrome（主）+ Firefox（备用） | 无 |
| **终端** | Ghostty（GPU 加速） | 无 |
| **输入法** | fcitx5 + rime | 无 |
| **主题** | Catppuccin Macchiato | — |
| **容器** | 无 | 无 |
| **网络** | NetworkManager | NetworkManager |
| **登录管理** | greetd + tuigreet（会话菜单切换合成器） | SSH |

### 两个主机配置

| 主机名 | Flake 输出 | 说明 |
|--------|-----------|------|
| `misty-desktop` | `.#misty-desktop` | Niri / Hyprland 双合成器日常桌面 |
| `misty-server` | `.#misty-server` | 运行在虚拟化环境中的服务器 |

## 📁 目录结构

```
nixos-config/
├── flake.nix                    # Flake 入口（nixpkgs/home-manager/catppuccin/noctalia/hyprland/disko/sops-nix/nur）
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
│       └── virtualisation.nix   #     虚拟化客户机工具（QEMU 客户机 + 服务器基础工具）
│
├── home/                        # 用户级模块（home-manager）
│   ├── base/                    #   跨平台用户配置
│   │   ├── core/                #     核心配置
│   │   │   ├── shells.nix       #       zsh + starship
│   │   │   ├── editor.nix       #       vim（默认编辑器）
│   │   │   ├── git.nix          #       git + delta + lazygit
│   │   │   └── tools.nix        #       eza/bat/fzf/zoxide/btop/yazi/rg/fd
│   │   └── gui/                 #     GUI 配置
│   │       ├── terminal.nix     #       Ghostty 终端
│   │       ├── browsers.nix     #       Chrome（主）+ Firefox（备用）
│   │       ├── vscode.nix       #       VS Code 图形编辑器
│   │       └── media.nix        #       mpv/pavucontrol/imv
│   ├── linux/gui/
│   │   ├── niri.nix             #       Niri WM（mkIf 条件启用）
│   │   ├── niri/conf/           #       Niri KDL 配置文件
│   │   ├── noctalia.nix         #       Noctalia Shell（两个合成器共用）
│   │   ├── hyprland.nix         #       Hyprland WM（mkIf 条件启用）
│   │   └── fcitx5.nix           #       中文输入法
│   └── hosts/linux/             #   主机专属 home 入口
│       ├── misty-desktop.nix    #     双合成器桌面（显式导入并启用 niri + hyprland）
│       └── misty-server.nix     #     服务器（仅 CLI）
│
├── hosts/                       # 主机系统级配置
│   ├── misty-desktop/           #   双合成器桌面
│   │   ├── disko.nix            #     磁盘分区声明（disko）
│   │   └── hardware-configuration.nix  # 内核模块等硬件相关配置
│   └── misty-server/            #   服务器（disko.nix + qemu-guest）
│
└── outputs/
    └── default.nix              # 组装 2 个 nixosConfigurations
```

## 🚀 快速开始

### 1. 首次安装（从 NixOS ISO）

```bash
# 1. 从 NixOS 官方 ISO 启动 → https://nixos.org/download

# 2. 克隆配置仓库
git clone <你的仓库地址> ~/nixos-config
cd ~/nixos-config

# 3. ISO 环境默认未启用 Flakes，先临时开启（仅当前 shell 有效，
#    装好的系统配置中已永久启用，无需重复）
export NIX_CONFIG="experimental-features = nix-command flakes"

# 4. 确认目标磁盘设备名（⚠️ 下一步会清空该磁盘上的全部数据！）
lsblk

# 5. 修改 hosts/misty-server/disko.nix 顶部的 diskDevice 为实际磁盘设备

# 6. 声明式分区、格式化并挂载到 /mnt（磁盘布局由 disko.nix 定义）
sudo nix run github:nix-community/disko -- --mode destroy,format,mount hosts/misty-server/disko.nix

# 7. 部署 age 私钥到目标系统（sops 解密依赖，密钥生成见 secrets/README.md）
sudo mkdir -p /mnt/var/lib/sops-nix/age
sudo cp ~/.config/sops/age/keys.txt /mnt/var/lib/sops-nix/age/keys.txt
sudo chmod 600 /mnt/var/lib/sops-nix/age/keys.txt

# 8. 编辑 vars/default.nix，修改：
#    - useremail
#    - 密码哈希与 SSH 公钥由 sops-nix 管理，
#      如需修改执行 `sops secrets/secrets.yaml`（见 secrets/README.md）

# 9. 编辑 vars/networking.nix，修改网络配置

# 10. 安装 NixOS
sudo nixos-install --flake .#misty-server --no-root-password

# 11. 重启
reboot
```

> 磁盘分区布局由 [disko](https://github.com/nix-community/disko) 声明式管理，
> 装机时不再需要手动 `gdisk`/`mkfs`。`hardware-configuration.nix` 仅保留
> 内核模块等硬件相关配置。重装系统只需重复步骤 4-10，
> **注意重装会清空磁盘上的 age 私钥，必须重复步骤 7 重新部署**，
> 否则首次开机时 sops 无法解密用户密码与 SSH 公钥。

### 2. 日常部署

```bash
cd ~/nixos-config

# 桌面主机（Niri / Hyprland 双合成器）
sudo nixos-rebuild switch --flake .#misty-desktop

# 服务器
sudo nixos-rebuild switch --flake .#misty-server

# 仅设置下次启动配置
sudo nixos-rebuild boot --flake .#misty-desktop

# 测试配置（重启后恢复）
nixos-rebuild test --flake .#misty-desktop

# 远程部署到服务器
sudo nixos-rebuild switch --flake .#misty-server --target-host misty-server
```

> 首次远程部署新主机前，目标主机同样需要部署 age 私钥
> （`/var/lib/sops-nix/age/keys.txt`），否则 sops 无法解密。

### 3. 密钥管理（sops-nix）

密码哈希、SSH 公钥等敏感信息统一由 [sops-nix](https://github.com/Mic92/sops-nix) 管理，
完整说明见 [secrets/README.md](./secrets/README.md)，速查如下：

```bash
# 编辑加密密钥文件（保存时自动加密，可安全提交到 git）
sops secrets/secrets.yaml

# 解密验证
sops -d secrets/secrets.yaml

# 部署后检查（各主机上执行）
ls -la /run/secrets/
```

- **age 私钥**：部署到各主机 `/var/lib/sops-nix/age/keys.txt`（权限 600），
  丢失后无法解密，请务必备份；首次安装时的部署方式见上方安装流程步骤 6。
- **新增密钥三步**：`sops secrets/secrets.yaml` 添加 key →
  在 `modules/nixos/base/sops.nix` 注册 → 模块中引用解密路径。

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
| `Mod + W` | 打开浏览器 (Chrome) |
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
- 原生支持 Niri 和 Hyprland 工作区集成（通过 ext-workspace-v1 协议或 compositor-native backend）
- 两个合成器共用 Noctalia，配置一致，便于管理

## 🖥️ Hyprland 配置

- 配置文件：`home/linux/gui/hyprland.nix`（通过 `xdg.configFile` 写入 `~/.config/hypr/hyprland.conf`）
- 桌面 Shell：Noctalia（与 Niri 共用，`exec-once = noctalia` 启动）
- 自定义修改：编辑 `home/linux/gui/hyprland.nix` 中的 `xdg.configFile."hypr/hyprland.conf".text`
- 会话切换：登录界面（tuigreet）按 F3 或方向键选择 niri / Hyprland 会话

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

文件会被 `scanPaths` 自动导入，无需修改 `default.nix`（注意：`home/linux/gui/`
下的 WM 模块为例外，由主机入口显式导入）。

### 启用/停用某个合成器

桌面主机同时安装 Niri 与 Hyprland，登录时通过 tuigreet 会话菜单随时切换。
如需从构建中裁剪某个合成器，在 `home/hosts/linux/misty-desktop.nix` 中调整：

```nix
{ pkgs, ... }:
{
  imports = [
    ../../linux/gui.nix
    ../../linux/gui/niri.nix     # WM 模块显式导入
    ../../linux/gui/hyprland.nix
  ];
  modules.desktop.niri.enable = true;     # 停用 Niri 时改为 false
  modules.desktop.hyprland.enable = true; # 停用 Hyprland 时改为 false

  home.packages = with pkgs; [ steam ];
}
```

## ⚠️ 注意事项

1. **首次使用前必须修改**：
   - `vars/default.nix` 中的邮箱、网络配置
   - `hosts/*/disko.nix` 顶部的磁盘设备名（装机前用 `lsblk` 确认）
   - **密钥管理**：密码哈希与 SSH 公钥统一由 sops-nix 管理，
     执行 `sops secrets/secrets.yaml` 编辑 → 见 [secrets/README.md](./secrets/README.md)

2. **桌面 Shell 统一为 Noctalia**：
   - Niri 与 Hyprland 均使用 Noctalia 作为桌面 shell
   - Noctalia 原生支持 Niri 和 Hyprland 的工作区集成
   - Hyprland 配置通过 `home/linux/gui/hyprland.nix` 内联生成（`hyprland.conf`），无需外部 dotfiles 仓库

3. **服务器主机**：
   - 服务器配置为运行在虚拟化环境中的客户机（非提供虚拟化服务）
   - 默认导入 `qemu-guest.nix`（QEMU 客户机支持）
   - 提供基础服务器工具（tmux/rsync/jq/tcpdump 等）
   - 便于后续部署各种容器化服务

4. **国内镜像加速**：
   - `flake.nix` 中已配置 USTC 镜像

## 📚 参考资料

- [NixOS & Nix Flakes Book](https://github.com/ryan4yin/nixos-and-flakes-book)
- [Niri 配置文档](https://yalter.github.io/niri/)
- [Noctalia 文档](https://docs.noctalia.dev/noctalia/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Home Manager](https://nix-community.github.io/home-manager/)

## 📄 许可证

MIT
