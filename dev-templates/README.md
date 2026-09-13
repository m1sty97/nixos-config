# dev-templates — 项目级开发环境模板

按语言组合准备的最小 `flake.nix` 模板,项目内 `nix develop` 即得
与主机声明一致的工具链。项目依赖(依赖树/锁文件)由语言原生工具
管理,nix 只负责工具链本身。

## 使用

```bash
cp -r dev-templates/node-uv ~/proj/my-project/flake-template
cd ~/proj/my-project
nix develop
```

或直接引用(不复制):

```bash
nix develop ~/nixos-config/dev-templates/node-uv
```

## 模板列表

| 目录 | 工具链 | 包管理 | 适用 |
|------|--------|--------|------|
| `node-uv` | Node.js LTS + pnpm + uv | pnpm | TypeScript/JavaScript 为主、混合 Python 脚本的 AI 项目 |
| `python-uv` | Python 3 + uv | uv | Python 项目(uv 管理 venv 与依赖锁) |

## 依赖镜像约定

**新增模板必须同步声明对应生态的镜像配置**(shellHook 环境变量或
配置文件),当前映射:

| 生态 | 镜像 | 配置方式 |
|------|------|----------|
| PyPI(uv/pip) | [CERNET](https://mirrors.cernet.edu.cn/pypi/) `https://mirrors.cernet.edu.cn/pypi/simple` | `UV_DEFAULT_INDEX`(模板 shellHook);系统级 `/etc/uv/uv.toml` 已在 base 声明 |
| npm/pnpm registry | [npmmirror](https://registry.npmmirror.com)(CERNET 未收录 npm) | `NPM_CONFIG_REGISTRY`(模板 shellHook) |
| Go / Rust 等 | 暂未配置,新增模板时按 [CERNET 帮助](https://help.mirrors.cernet.edu.cn/) 补充(GOPROXY=goproxy.cn、RUSTUP 镜像等) | — |

## 约定

- 模板内 nixpkgs 默认跟随 `nixos-unstable`,项目可自行改锁;
- 新模板按 `语言组合命名`,保持最小化,不加业务依赖;
- 全局工具链版本在 modules/nixos/base/packages.nix 声明,模板与全局
  不一致时以模板为准(项目隔离);
- 全局 Python 不单独安装(避免 pip/PEP 668 脚枪),Python 统一走 uv。
