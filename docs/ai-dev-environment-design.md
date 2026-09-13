# AI 开发环境设计方案(TODO 2)

> 状态:已定案,待分阶段实施
> 决策方式:grilling 多轮问答(2026-09),每项决策附理由与备选
> 目标主机:misty-server(4C/8G 无 GPU 虚拟机,500G SSD + 可扩展 HDD)

## 1. 背景与目标

在 misty-server 上构建个人 AI 开发环境:

- **hermes**(Nous Research):个人 AI 助理,7×24 常驻,通过 Windows Web / 手机远程日常使用;
- **dsh**(DeepSeek Harness):coding agent,使用方式同上,并接受 hermes 的工作委派;
- **共享记忆 + RAG 知识库**:跨 agent 的记忆与文档检索服务,主要供 agent 以 API/MCP 消费,不依赖人机界面;
- **多语言开发环境**:常用语言工具链 + 项目级 devShell 模板,node/uv 依赖声明式管理;
- 模型统一走 **DeepSeek API**(无 GPU,不做本地推理;embedding 先本地小模型,语料大再切 API)。

约束:维护代价最低、部署形态收敛(最终仅两种:NixOS 模块、nix 环境 + systemd 服务)、8G 内存需给大头服务设上限。

## 2. 选型决策记录

| 领域 | 决策 | 落选方案与理由 |
|------|------|----------------|
| Agent Harness | hermes(Nous Research,官方 NixOS 模块)+ dsh(官方 npm 包 `@deepseek-ai/dsh`) | 两者是用户指定;hermes 走系统服务形态,dsh 走 nodejs + npm 用户层安装 |
| hermes 部署 | NixOS 系统服务模块(官方支持),非 Home Manager 单用户形态 | 助理需 7×24 常驻、离场可访问,HM 会话绑定形态不合 |
| dsh 部署 | nix 声明 nodejs 运行时 + `npm install -g @deepseek-ai/dsh` + systemd 托管 `dsh web` | buildNpmPackage 全声明式被否:预览版迭代快,每次升级更 npmDepsHash 成本过高;稳定后再收编 |
| 记忆服务 | **Hindsight**(vectorize-io):MCP + REST 双接口,retain/recall/reflect | mcp-memory-service(最轻,作降级替补)、Mem0+OpenMemory(要 Postgres+Qdrant,8G 偏重)、Zep/Graphiti(要 Neo4j)、Letta(重) |
| RAG 服务 | **LightRAG Server**(HKUDS):REST API + MCP(`lightrag-mcp`)+ 知识图谱检索 + 文档 ingest | Open WebUI(聊天 UI 优先,RAG 非核心,大部分功能冗余)、khoj(定位"第二助理",与 hermes 重叠)、RAGFlow(要 ES,8G 扛不动)、RAGLight/LightRAG 框架自建服务(维护成本最高) |
| 记忆与知识库 | **两件套**(Hindsight + LightRAG),不搞融合单系统 | 融合方案(cognee/OpenViking/MemOS)均为 2025-2026 年幼项目,无 Web UI,OpenViking 官方推荐 Docker(容器要回归);记忆(片段回填)与知识库(文档块检索)本就是两类消费;半年后视 cognee/OpenViking 成熟度再评估 |
| 存储策略 | 各服务自带嵌入式存储(SQLite 等),**不部署共享 PostgreSQL** | 跨应用共享已由 Hindsight/LightRAG 的 API/MCP 解决;备份靠 btrfs 子卷快照;PG 引入条件:LightRAG 大语料时用其 PG 后端,按需单配 |
| 委派机制 | hermes 通过 shell 工具调用同机 dsh CLI | 任务队列/消息总线在单用户场景过度设计,先用先看 |
| 数据接入 | `/srv/knowledge` 监听目录(nix 声明)+ agent 执行数据收集 | 定时 cron 仅作兜底;个人文档/笔记、代码仓库文档、网页剪藏三类来源,互联网应用数据由 agent 按指令采集落盘 |
| 局域网安全 | 暂缓:服务监听内网,Caddy 反代/TLS/Tailscale 后续单独议题 | — |

## 3. 服务拓扑

| 服务 | 形态 | 端口(默认,部署时核对) | 数据路径 | 内存上限 |
|------|------|------------------------|----------|----------|
| hermes-agent | NixOS 模块(系统服务) | Web UI 端口以官方模块默认为准 | `/var/lib/hermes` | 1.5G |
| dsh | nix nodejs + systemd 服务 | Web UI 3080(内部 3079) | `/var/lib/dsh` | 1G |
| Hindsight | nix Python venv + systemd | REST API(默认端口部署时核对)+ MCP | `/var/lib/hindsight` | 1G |
| LightRAG Server | nix Python venv + systemd | API/WebUI 9621 + Ollama 兼容接口 | `/var/lib/lightrag`,知识源 `/srv/knowledge` | 1.5G |
| 系统 + 余量 | — | — | — | ~2G |

- 所有服务监听绑定内网(10.1.77.6 / 0.0.0.0),安全加固为延后议题;
- systemd `MemoryMax` 上限先按表设置,运行一段时间后调整;
- Ollama 兼容接口使 LightRAG 可被当作本地"知识库模型"接入任何支持 Ollama 的客户端。

## 4. 数据流与消费关系

```
Windows Web / 手机
        │  (局域网 HTTP,安全加固后议题)
        ▼
hermes ──────────────┐            dsh ──────────────┐
 (NixOS 服务)        │ shell 委派   (systemd 服务)  │
        │            ▼              │              ▼
        ├── MCP/REST ─→ Hindsight(共享记忆)←─ MCP/REST ─┤
        ├── MCP/REST ─→ LightRAG(知识库 RAG)←─ MCP/REST ─┤
        └── /srv/knowledge 监听目录 ←── agent 执行数据收集 ←┘
```

- 记忆与知识库是两类消费:记忆为"片段回填上下文",知识库为"文档块检索";
- hermes 内置学习闭环保持不动,外部共享记忆仅存跨工具事实(偏好/项目上下文/决策);
- 数据收集:平时口述需求,由 hermes/dsh 采集互联网应用数据落到 `/srv/knowledge`。

## 5. 开发环境(多语言声明式)

- **全局(NixOS 声明,base 层)**:nodejs(LTS)、uv、git、gh、常用 CLI;
- **项目级(devShell 模板,仓库 `dev-templates/` 新增)**:
  - `node-uv` 模板:nodejs + uv + 常用工具,项目内 `nix develop` 进入;
  - `python-uv` 模板:python + uv(venv/lock 由 uv 管理,nix 不插手项目依赖);
  - 按需再加 go / rust 模板;
- **node / uv 的声明式边界**(本轮结论):工具链版本全局声明;项目依赖由语言原生工具管理,nix 只锁工具链不锁业务依赖。

## 6. 实施阶段(每阶段过 `nix flake check` 后 switch)

1. **开发环境**:base 层全局工具(nodejs/uv)+ `dev-templates/` 模板;
2. **hermes**:引入官方 NixOS 模块,配置 DeepSeek API、远程访问;
3. **dsh**:nodejs 运行时 + npm 安装 + systemd 服务 + Web UI;
4. **Hindsight**:Python venv 打包 + systemd + DeepSeek API 接入;
5. **LightRAG**:Python venv 打包 + systemd + `/srv/knowledge` 监听目录;
6. **收尾**:systemd 内存上限、btrfs 快照任务(snapper)、运行观测与调优。

## 7. 延后议题

- 局域网安全加固(Caddy 反代 / TLS / Tailscale);
- embedding 与各服务模型参数(选型已定,实施时按语料规模定);
- 内存上限数值调优;
- 共享 PostgreSQL 引入条件(LightRAG 大语料切 PG 后端);
- 融合系统再评估(cognee / OpenViking / MemOS 出稳定版与 Web UI 后)。

## 8. 调研引用

- hermes-agent:[GitHub](https://github.com/nousresearch/hermes-agent) · [Nix 官方文档](https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup)
- dsh:[官方安装文档](https://www.runoob.com/deepseek-harness/deepseek-harness-install.html) · [社区 Docker 方案](https://github.com/deepseek-ai/deepseek-harness/discussions/1762)
- Hindsight:[vectorize-io/hindsight](https://github.com/vectorize-io/hindsight) · [文档](https://hindsight.vectorize.io/)
- LightRAG:[HKUDS/LightRAG](https://github.com/HKUDS/LightRAG) · [API Server 文档](https://github.com/HKUDS/LightRAG/blob/main/docs/LightRAG-API-Server-zh.md) · [lightrag-mcp](https://pypi.org/project/lightrag-mcp/)
- 记忆方案横评:[Mem0 vs Zep vs Letta(2026)](https://www.developersdigest.tech/blog/best-ai-agent-memory-providers-2026) · [mcp-memory-service](https://github.com/doobidoo/mcp-memory-service)
- 融合方案观察对象:[cognee](https://github.com/topoteretes/cognee) · [MemOS](https://github.com/MemTensor/MemOS) · [OpenViking](https://github.com/volcengine/OpenViking)
- RAG 对比参考:[RAGLight](https://github.com/Bessouat40/RAGLight) · [LightRAG](https://github.com/hkuds/lightrag)
