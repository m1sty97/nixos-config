# Hermes Agent 使用指南（misty-server）

> 状态：阶段 2 已部署（deepseek-flash + Web dashboard），鉴权凭据经 sops 注入
> 相关文档：[ai-dev-environment-design.md](./ai-dev-environment-design.md)（选型与阶段规划）
> 模块源码：[nix/moduleCommon.nix](https://github.com/NousResearch/hermes-agent/blob/main/nix/moduleCommon.nix) · [nixosModules.nix](https://github.com/NousResearch/hermes-agent/blob/main/nix/nixosModules.nix)

## 1. 概述

Hermes（Nous Research）是 7×24 常驻的个人 AI 助理，通过官方 flake 提供的 NixOS 模块以系统服务形态部署在 misty-server 上：

- 模型：DeepSeek API（`deepseek-flash` @ `https://api.deepseek.com`，官方 base_url 不带 `/v1`）；
- 访问：局域网浏览器 / 手机访问 Web dashboard（9119 端口），SSH 内使用 `hermes` CLI，桌面端 app（Hermes Desktop）经 `/api` 直连；
- 密钥：全部经 sops-nix 注入，仓库中无明文。

**涉及文件**

| 文件 | 作用 |
|---|---|
| `hosts/misty-server/ai/hermes.nix` | 服务配置（AI 服务严格隔离在此，勿移入 base/server 模块组） |
| `flake.nix` | `hermes-agent` flake input（不跟随 nixpkgs，独立演进） |
| `secrets/secrets.yaml` | `hermes-env` 密钥（多行 KEY=VALUE） |
| `modules/nixos/base/sops.nix` | sops 框架 |

## 2. 运行架构

启用后创建**两个** systemd 服务（共享 `HERMES_HOME=/var/lib/hermes/.hermes`）：

| 服务 | 进程 | 用途 |
|---|---|---|
| `hermes-agent.service` | `hermes gateway` | 消息平台网关（Telegram/Discord 等），暂未使用但常驻 |
| `hermes-backend.service` | `hermes dashboard --host 0.0.0.0 --port 9119` | Web 面板 + `/api/ws`、`/api/pty`（桌面端/浏览器） |

目录约定：状态数据在 `/var/lib/hermes/.hermes/`（config.yaml、.env、memories/、sessions/、cron/、logs/、plugins/），agent 工作目录 `/var/lib/hermes/workspace`（即 config.yaml 的 `terminal.cwd`）。服务以 `hermes:hermes` 用户运行，`ProtectSystem=strict` 下仅可写 stateDir 与工作目录。

## 3. 当前配置解读（hermes.nix）

| 配置 | 值 | 说明 |
|---|---|---|
| `settings.model.default` | `deepseek-flash` | 主模型 |
| `settings.model.base_url` | `https://api.deepseek.com` | DeepSeek 官方根路径，**不带 `/v1`** |
| `backend.mode` | `dashboard` | serve 全部能力 + Web 面板（同端口） |
| `backend.host/port` | `0.0.0.0` / `9119` | 绑定非 loopback 触发鉴权门；绑 0.0.0.0 时接受任意 Host 头（防 rebinding 校验对 0.0.0.0 放行） |
| `addToSystemPackages` | true | CLI 进系统 PATH、全局导出 `HERMES_HOME`，SSH 与未来 dsh 委派依赖此项 |
| `environmentFiles` | sops `hermes-env` | 激活时合并进 `$HERMES_HOME/.env`，hermes 每次启动读取 |

## 4. 密钥与 dashboard 鉴权

**sops key 命名约定**：必须用连字符扁平 key `hermes-env`——`sops.secrets."a/b"` 的斜杠会被 sops-nix 解释为嵌套路径，字面量 `a/b:` 顶层 key 会导致激活构建失败（"the key 'a' cannot be found"）。

`hermes-env` 当前内容（systemd/dotenv 格式的 KEY=VALUE）：

```
DEEPSEEK_API_KEY=...                        # 主模型密钥
HERMES_DASHBOARD_BASIC_AUTH_USERNAME=...    # dashboard 登录用户名
HERMES_DASHBOARD_BASIC_AUTH_PASSWORD_HASH=  # scrypt hash（scrypt$16384$8$1$<salt_b64>$<dk_b64>）
HERMES_DASHBOARD_BASIC_AUTH_SECRET=...      # 会话签名密钥（openssl rand -base64 32），使会话跨重启有效
```

**鉴权门规则**：绑定非 loopback 地址时必须有密码或 OAuth provider，否则 dashboard **fail-closed 拒绝绑定**（systemd 非交互环境不会出现"首次设置"引导）。凭据缺失是最可能的"9119 无法访问"原因。

**修改登录密码**（明文密码不落盘，只存 scrypt hash）：

```bash
# 1. 生成 hash（服务器上执行；read -rs 避免密码进 history）
read -rs DASH_PW && export DASH_PW
python3 - <<'EOF'
import hashlib, base64, secrets, os
salt = secrets.token_bytes(16)
dk = hashlib.scrypt(os.environ["DASH_PW"].encode(), salt=salt, n=2**14, r=8, p=1, dklen=32)
print("scrypt$16384$8$1$" + base64.b64encode(salt).decode() + "$" + base64.b64encode(dk).decode())
EOF
unset DASH_PW
# 2. sops secrets/secrets.yaml 更新 _PASSWORD_HASH 行（勿再设 _PASSWORD，二者同存时明文优先）
# 3. git 提交 + sudo nixos-rebuild switch（或 systemctl restart hermes-backend）
```

## 5. 配置持久化规则

| 改动来源 | 存哪 | rebuild 后 |
|---|---|---|
| dashboard/桌面端/CLI 改 **Nix 未声明**的键 | 磁盘 config.yaml | **存活** |
| 同上，改 **Nix 已声明**的键 | 磁盘 config.yaml | 被 Nix 值覆盖（回退） |
| sops 改 `hermes-env` | .env（激活时全量重建） | 需重启服务生效 |
| 手动改 .env | — | 丢失 |
| 会话/记忆/cron 等运行数据 | `/var/lib/hermes` | 存活（模块只建目录不碰内容） |

要点：

- config.yaml 是普通文件（非 store 符号链接），Nix `settings` 通过**深度合并**写入：Nix 键覆盖同名磁盘键，其余键保留；
- 从 Nix settings **删除**某个键不会删除磁盘旧值，残留值继续生效，需手动清理一次；
- 受管模式（`HERMES_MANAGED`）只拦截 `hermes update` / `hermes setup` / gateway 服务安装这三类自变更命令，**不拦截配置写入**——桌面端/面板改设置随时可保存；
- 运维姿势：面板上试参数 → 稳定后固化进 `hermes.nix` → rebuild，两边不打架。

## 6. 日常使用

**浏览器**：`http://10.1.77.6:9119`，用 sops 中配置的用户名 + 明文密码登录（不是 hash）。

**桌面端 app**：连接 `10.1.77.6:9119` 的 backend。agent 配置改动保存在服务端 config.yaml（规则同上）；app 自身界面偏好存在本地。

**CLI（SSH）**：`hermes` 直接可用（与服务共享会话/记忆/技能）。常用：

```bash
hermes              # 交互 TUI
hermes config       # 查看配置及来源
hermes doctor       # 环境自检
```

## 7. 运维命令速查

```bash
# 部署
cd ~/nixos-config && sudo nixos-rebuild switch --flake .#misty-server

# 服务管理（注意有两个单元）
systemctl status hermes-agent hermes-backend
sudo systemctl restart hermes-backend          # 改 sops 密钥后只需重启
journalctl -u hermes-backend -f                # 面板/后端日志
journalctl -u hermes-agent -f                  # 网关日志

# 验证
ss -tlnp | grep 9119                           # 确认监听
curl -I http://127.0.0.1:9119                  # 本机连通性
```

部署后检查清单：两个单元均 active → 浏览器登录 dashboard → SSH `hermes` 可用 → 下一轮会话正常应答。

## 8. 已知现象与注意事项

- **辅助模型 WARNING**（`nous/openrouter unhealthy`、视觉/X 搜索/视频工具不可用）：辅助能力缺对应 key 的正常现象，不影响 DeepSeek 主模型与会话；后续可把 `settings.auxiliary.*` 指向 DeepSeek 消除；
- **gateway 常驻**：未接消息平台时 `hermes-agent.service` 也占用资源，设内存上限时按两个进程合计；
- **写权限边界**：服务只能写 `/var/lib/hermes`（含 workspace）；未来要写 `/srv/knowledge` 需对两个 unit 追加 `ReadWritePaths`；
- **升级**：`flake.lock` 中 hermes-agent 不跟随 nixpkgs，单独 `nix flake update hermes-agent` 或随全量更新；该 flake 属上游 best-effort，出问题可锁旧 rev 或转 `container.enable` 形态（注意容器模式与 dashboard 互斥）。

## 9. 后续规划（对应设计文档阶段 4-6）

- Hindsight（记忆）与 LightRAG（知识库）经 `settings.mcpServers` 接入，Hindsight 依赖组走 `extraDependencyGroups = [ "hindsight" ]`；
- agent 人设走 `hermesHomeFiles."SOUL.md"` 声明式管理（SOUL.md 只从 HERMES_HOME 读取）；
- systemd 内存上限（gateway + backend 分摊设计文档 §3 的 1.5G 预算）；
- `/srv/knowledge` 数据接入与 ReadWritePaths 放行。
