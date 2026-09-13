# AGENTS.md — 项目 Agent 工作指南

本仓库是个人 NixOS 配置（Flakes + home-manager），管理两台主机：
`misty-desktop`（Niri / Hyprland 双合成器桌面 + Noctalia，登录时可切换）、
`misty-server`（虚拟化环境中的服务器）。所有 Agent 在本仓库中工作前，**必须**阅读并遵守本文档。

---

## 1. 写代码前要做什么

### 1.1 理解现有结构

- **先读再写**。修改任何文件前，先读取目标文件及其上下游依赖（`imports`、`specialArgs`
  传递的 `myvars`/`mylib`/`inputs`），确认改动不会破坏模块组装链。
- **理解 scanPaths 机制**。`lib/default.nix` 中的 `scanPaths` 会自动导入目录下所有 `.nix`
  文件（排除 `default.nix`）和子目录。新增模块文件会被自动导入，删除文件会自动移除导入——
  无需手动修改 `default.nix`。
- **理解三层分离**。`modules/nixos/base/`（所有主机共享）→ `modules/nixos/desktop/`（桌面）
  或 `modules/nixos/server/`（服务器）→ `hosts/<主机名>/`（主机特定）。改动放在哪一层，
  取决于其影响范围：全主机 → base，仅桌面 → desktop，仅服务器 → server，仅单台主机 → hosts。

### 1.2 确认变量与约定

- **禁止硬编码用户名、邮箱、网络地址**。这些值统一在 `vars/default.nix` 和
  `vars/networking.nix` 中定义，通过 `myvars` 引用。
- **flake inputs 在 `flake.nix` 顶部定义**，新增 input 需添加 `follows` 声明以保持
  nixpkgs 版本一致。`outputs/default.nix` 中的 `genSpecialArgs` 负责将 `inputs`、
  `mylib`、`myvars`、`pkgs-stable` 传递给所有模块。
- **主机在 `outputs/default.nix` 中组装**。新增主机需要同步创建：
  `hosts/<名>/default.nix` + `hosts/<名>/disko.nix` +
  `hosts/<名>/hardware-configuration.nix` +
  `home/hosts/linux/<名>.nix` + 在 `outputs/default.nix` 中添加 `nixosConfigurations` 条目。
- **新增服务器优先使用模板**：复制 `hosts/server-template/` 与
  `home/hosts/linux/server-template.nix`（七步流程见模板头注释），
  全局替换 `TEMPLATE_HOST` 后按需个性化；outputs 中有注释好的注册示例。
  模板目录未被 flake 注册，不会被构建。桌面主机保持 bespoke，不走模板。
- **磁盘布局由 disko 声明式管理**。每台主机的分区/格式化定义在 `hosts/<名>/disko.nix`，
  挂载点由 disko 自动生成；`hardware-configuration.nix` 仅保留内核模块等硬件相关配置，
  **不要在其中重复定义 `fileSystems` / `swapDevices`**，否则与 disko 生成的内容冲突。
  `disko.nix` 顶部的 `diskDevice` 需在装机前用 `lsblk` 确认实际磁盘设备名。

### 1.3 环境检查

- 本仓库在 **Windows 环境下开发**，但目标系统是 **Linux (NixOS)**。
  本地无法运行 `nix eval` / `nixos-rebuild`，只能做静态检查（括号匹配、文件引用完整性）。
  完整验证需在 NixOS 机器上执行。
- Git 全局配置已设为 `user.name = m1sty97`、`user.email = wei251x@gmail.com`。
  如需修改，通过 `git config` 命令操作，不要编辑配置文件。

---

## 2. 工作过程中怎么守规矩

### 2.1 注释与文档语言

- **所有注释、文档使用中文**。包括：
  - `.nix` 文件中的注释（`#` 行注释、`/* */` 块注释）
  - `.kdl` 文件中的注释（`//` 行注释）
  - `.json` / `.toml` 等配置文件中如有注释字段，使用中文
  - `README.md` 及其他 Markdown 文档
  - Git commit message（见 §2.5）
- 注释应说明 **"为什么这样做"** 而非 "做了什么"（代码本身已表达做了什么）。
  对于非显而易见的配置项，说明其作用和取值原因。
- 每个文件顶部应有 **文件头注释块**，说明文件用途、所属模块层级、关键配置项。
  参考现有文件的格式（如 `modules/nixos/base/nix.nix`）。

### 2.2 Nix 代码规范

- **文件名**：使用 `kebab-case.nix`（如 `hardware-configuration.nix`）。
- **属性导入**：优先使用 `inherit (...)` 而非逐个赋值。
- **条件配置**：使用 `lib.mkIf`、`lib.optional`、`lib.optionals`。
- **默认值**：使用 `lib.mkDefault` 设置默认值，仅在必须覆盖时使用 `lib.mkForce`。
  理解 `mkDefault` 的优先级机制——子模块可以直接赋值覆盖 `mkDefault`，无需 `mkForce`。
- **模块选项**：自定义 `options` 必须有 `description`。
- **格式化**：Nix 代码使用 `nixfmt` 格式化，宽度 100。命令：`nix fmt`。
- **避免 `with lib`**：除非文件简短且清晰，否则显式写 `lib.mkIf` 而非 `with lib; mkIf`，
  避免命名冲突风险。（现有 `modules/nixos/desktop.nix` 和 `hyprland.nix` 使用了 `with lib`，
  保持不动，但新文件避免使用。）

### 2.3 模块化原则

- **单一职责**：每个 `.nix` 文件聚焦一个功能领域（如 `fonts.nix` 只管字体、`ssh.nix` 只管 SSH）。
- **通过 scanPaths 自动导入**：新增模块文件放入对应目录即可被自动导入，不要手动编辑
  `default.nix` 的 `imports` 列表（`default.nix` 只包含 `imports = mylib.scanPaths ./.;`）。
- **跨平台复用**：`home/base/` 下的配置对所有平台生效，`home/linux/` 仅 Linux 生效。
  桌面专属配置放 `home/base/gui/` 或 `home/linux/gui/`，服务器仅 CLI 配置放 `home/linux/base/`。
- **WM 显式导入 + 条件启用**：`home/linux/gui/default.nix` 只导入共用的 GUI 配置
  （noctalia、fcitx5）；WM 模块（`niri.nix`、`hyprland.nix`）由桌面主机的
  `home/hosts/linux/misty-desktop.nix` 显式导入。两者均使用 `mkEnableOption + mkIf`，
  可同时启用（登录时通过 tuigreet 会话菜单切换），也可只启用其一。新增 WM 遵循同样模式。

### 2.4 配置文件链接方式

- Niri 的 KDL 配置通过 `xdg.configFile` + `mkOutOfStoreSymlink` 链接到 `~/.config/niri/`，
  使配置修改无需重新部署即可生效。链接源路径基于 `config.home.homeDirectory`，不要硬编码绝对路径。
- Hyprland 配置通过 `xdg.configFile` 内联写入 `~/.config/hypr/hyprland.conf`，无需外部 dotfiles 仓库。
- 桌面主机的两个合成器统一使用 Noctalia 作为桌面 shell，通过 `home/linux/gui/noctalia.nix` 统一配置。

### 2.5 Git 提交规范

- **Commit message 使用英文**，格式：`<prefix>: <english description>`。
- 常用前缀：
  - `init:` — 初始化/新建
  - `add:` — 新增功能/模块/主机
  - `fix:` — 修复问题
  - `refactor:` — 重构（不改变行为）
  - `docs:` — 文档变更
  - `chore:` — 杂项（格式化、依赖更新等）
  - `server:` / `desktop:` / `hyprland:` / `niri:` — 按主机/合成器限定
- 提交 message 正文（如有）使用英文，每行不超过 72 字符。
- **一个提交只做一件事**。不要在同一个提交中混合功能新增和代码重构。
  同一改动涉及的文档同步（如 README/AGENTS.md 中对应章节的更新）视为该改动
  的一部分，可以随代码一并提交，无需拆出单独的 docs 提交；只有与代码改动
  无关的独立文档变更才单独使用 `docs:` 前缀提交。
- **提交前必须 `git add -A` 并 `git status --short` 检查**，确认没有遗漏或多余文件。
- **每次工作结束只提交到本地**，未经用户明确要求不得推送到远端；用户要求推送时，
  先整理本地全部提交（确认消息符合规范、无多余或不完整提交）后再推送。
- **禁止 `--amend` 已推送的提交**。`git push --force` 到主分支仅允许在
  用户明确要求的历史重写（如提交信息英文化、敏感信息清除）之后使用，
  且使用前必须完成受影响密钥/凭据的轮换评估。

### 2.6 敏感信息处理

- **所有敏感信息通过 sops-nix 管理**（密码哈希、SSH 私钥、API token 等）。
  加密文件在 `secrets/secrets.yaml`，配置在 `.sops.yaml`，系统模块在 `modules/nixos/base/sops.nix`。
  参见 [secrets/README.md](./secrets/README.md)。
- **age 私钥（`keys.txt`）绝对不能提交到 git**（已在 `.gitignore` 中排除）。
  私钥部署到各主机的 `/var/lib/sops-nix/age/keys.txt`。
- **明文密码、密码哈希明文不在代码中出现**。用户密码哈希与 SSH 公钥统一由
  sops-nix 解密提供，`vars/` 中不保留明文回退占位符。
- 新增敏感配置时，通过 `sops secrets/secrets.yaml` 添加 key，然后在
  `modules/nixos/base/sops.nix` 的 `sops.secrets` 中注册，在需要使用的模块中通过
  `config.sops.secrets."key/path".path` 引用解密后的文件路径。
- `hosts/*/hardware-configuration.nix` 包含硬件特定信息，已加入版本控制（占位文件），
  用户首次安装后替换为实际配置。

---

## 3. 收尾时要检查什么

### 3.1 代码检查

- [ ] **括号匹配**：所有 `.nix` 文件的 `{}`/`[]`/`()` 配对正确。
- [ ] **文件引用完整**：所有 `imports` 中引用的文件路径存在且正确。
  特别是相对路径（`./xxx.nix`、`../../modules/...`）的层级是否正确。
- [ ] **scanPaths 一致性**：如果新增/删除了目录下的 `.nix` 文件，确认 `scanPaths` 会正确
  包含/排除它（`default.nix` 会被排除，其余 `.nix` 文件会被包含）。
- [ ] **无硬编码**：用户名、邮箱、网络地址等通过 `myvars` 引用，没有硬编码字符串。
- [ ] **mkDefault 优先级**：覆盖 `mkDefault` 值时使用直接赋值（不需 `mkForce`）；
  覆盖 `mkForce` 时需谨慎，确认是否有更合理的方案。
- [ ] **注释为中文**：新增/修改的注释使用中文，文件头注释块完整。

### 3.2 语法格式

- [ ] 运行 `nix fmt`（如有 Nix 环境）格式化所有 `.nix` 文件。
- [ ] 检查 `git diff --check` 无空白错误。
- [ ] `flake.lock` 已有意纳入版本控制。依赖更新由 `nix flake update` 产生，
  将其变更以 `chore:` 前缀单独提交，不要与其他功能改动混在一起。

### 3.3 功能验证

- [ ] **静态检查**（本地可做）：括号匹配、文件引用、scanPaths 一致性、无硬编码。
- [ ] **构建验证**（需 NixOS 环境）：`nix eval .#nixosConfigurations.<主机名>` 或
  `nixos-rebuild build --flake .#<主机名> --dry-run`。
  如果本地无法运行，在提交信息中注明"未经 nix build 验证"。
- [ ] **跨主机影响**：修改 `base/` 下模块会影响所有主机，确认不会破坏其他主机的配置。
  如果修改了 `base/networking.nix`，同时检查桌面和服务器主机是否受影响。

### 3.4 提交检查

- [ ] `git status --short` 显示干净的暂存区（只有预期文件）。
- [ ] Commit message 符合 §2.5 规范（中文描述 + 英文前缀）。
- [ ] 一个提交只做一件事，没有混合不相关的改动。
- [ ] `.gitignore` 正确排除 `result`、`result-*`、临时文件、age 私钥、sops 明文文件。
- [ ] 如果修改了 `secrets/secrets.yaml`，确认文件已被 sops 加密（文件顶部有 `sops:` metadata），
      没有意外提交明文内容。

### 3.5 文档同步

- [ ] 如果新增/删除了主机、模块或 flake input，同步更新 `README.md` 中的目录结构和组件概览。
- [ ] 如果新增了主机，在 `outputs/default.nix` 中添加对应的 `nixosConfigurations` 条目，
  并在 `README.md` 的"三个主机配置"表格中添加一行。
- [ ] 如果修改了工作流程或规范，同步更新本文件（`AGENTS.md`）。

---

## 4. 项目结构速查

```
nixos-config/
├── flake.nix              # 入口：定义 inputs（含 sops-nix）
├── flake.lock             # 依赖锁定文件（有意提交到版本控制）
├── dev-templates/         # 项目级 devShell 模板（node-uv / python-uv）
├── install.sh             # 首次安装/重装一键脚本（NixOS ISO 环境执行）
├── .sops.yaml             # sops 加密配置（age 公钥）
├── outputs/default.nix    # 组装 nixosConfigurations（2 台主机）
├── lib/                   # mylib：scanPaths / nixosSystem
├── vars/                  # myvars：用户名 / 网络 / SSH（非敏感）
├── secrets/               # sops 加密密钥文件
│   ├── secrets.yaml       #   加密的密码哈希、SSH 公钥等
│   └── README.md          #   密钥管理使用指南
├── modules/nixos/         # 系统级模块
│   ├── base/              #   所有主机共享（含 sops.nix）
│   ├── desktop/           #   桌面专属
│   ├── server/            #   服务器专属
│   ├── desktop.nix        #   桌面入口
│   └── hyprland.nix       #   Hyprland 系统级
├── home/                  # home-manager 用户级
│   ├── base/core/         #   核心配置（zsh/starship/vim/git/tools）
│   ├── base/gui/          #   GUI 配置（ghostty/browsers/media/vscode/gtk）
│   ├── linux/gui/         #   GUI 配置（noctalia/fcitx5 共用 + niri/hyprland WM 模块）
│   └── hosts/linux/       #   主机专属 home 入口
└── hosts/                 # 主机系统级配置（每台含 disko.nix 磁盘布局）
    ├── misty-desktop/     #   双合成器桌面（Niri / Hyprland）
    └── misty-server/      #   服务器
```

## 5. 部署命令速查

```bash
sudo nixos-rebuild switch --flake .#misty-desktop    # 桌面（Niri / Hyprland 登录时切换）
sudo nixos-rebuild switch --flake .#misty-server    # 服务器
nix flake update                                     # 更新所有 inputs
nix fmt                                              # 格式化 Nix 代码
# ⚠️ 装机分区（清空目标磁盘，设备名见 hosts/<名>/disko.nix）
sudo nix run github:nix-community/disko -- --mode destroy,format,mount hosts/<名>/disko.nix
```

## 6. 参考文档

- [README.md](./README.md) — 项目总览、安装部署指南、快捷键速查
- [NixOS & Nix Flakes Book](https://github.com/ryan4yin/nixos-and-flakes-book) — NixOS 入门
- [Niri 配置文档](https://yalter.github.io/niri/) — Niri WM 配置
- [Noctalia 文档](https://docs.noctalia.dev/noctalia/) — Noctalia Shell 配置
- [Hyprland Wiki](https://wiki.hyprland.org/) — Hyprland 配置
- [Home Manager](https://nix-community.github.io/home-manager/) — 用户环境管理
