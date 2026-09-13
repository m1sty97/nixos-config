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

| 目录 | 工具链 | 适用 |
|------|--------|------|
| `node-uv` | Node.js LTS + uv | TypeScript/JavaScript 为主、混合 Python 脚本的 AI 项目 |
| `python-uv` | Python 3 + uv | Python 项目(uv 管理 venv 与依赖锁) |

## 约定

- 模板内 nixpkgs 默认跟随 `nixos-unstable`,项目可自行改锁;
- 新模板按 `语言组合命名`,保持最小化,不加业务依赖;
- 全局工具链版本在 modules/nixos/base/packages.nix 声明,模板与全局
  不一致时以模板为准(项目隔离)。
