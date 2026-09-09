# secrets/ — sops-nix 密钥管理

本目录存放通过 [sops](https://github.com/getsops/sops) + [sops-nix](https://github.com/Mic92/sops-nix) 加密的密钥文件。

## 架构

```
secrets/secrets.yaml  ← sops 加密的 YAML 文件（安全提交到 git）
.sops.yaml            ← sops 配置（定义加密规则和 age 公钥）
```

构建时 sops-nix 使用 age 私钥（`/var/lib/sops-nix/age/keys.txt`）解密 `secrets.yaml`，
将明文写入 `/run/secrets/`（tmpfs，重启后消失）。

## 首次设置

### 1. 生成 age 密钥对

```bash
# 进入开发环境（包含 age 工具）
nix develop

# 生成 age 密钥对
age-keygen -o ~/.config/sops/age/keys.txt
# 输出类似：
# # created: 2026-09-08T12:00:00Z
# # public key: age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

### 2. 配置 .sops.yaml

将上一步生成的公钥（`age1...` 开头）填入项目根目录的 `.sops.yaml`：

```yaml
creation_rules:
  - path_regex: secrets/.*\.yaml$
    age:
      - "age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### 3. 编辑加密密钥文件

```bash
# 使用 sops 编辑密钥文件（自动加密后保存）
sops secrets/secrets.yaml
```

在编辑器中填入实际的密钥值：

```yaml
misty:
    hashed_password: "$y$j9T$你的真实密码哈希"
ssh:
    authorized_keys:
        - "ssh-ed25519 AAAA... misty@desktop"
```

### 4. 部署 age 私钥到主机

各主机需要 age 私钥才能解密：

```bash
# 将 age 私钥复制到目标主机
sudo mkdir -p /var/lib/sops-nix/age
sudo cp ~/.config/sops/age/keys.txt /var/lib/sops-nix/age/keys.txt
sudo chmod 600 /var/lib/sops-nix/age/keys.txt
```

### 5. 验证

```bash
# 解密验证（查看明文内容）
sops -d secrets/secrets.yaml

# 部署后检查
ls -la /run/secrets/
cat /run/secrets/misty/hashed_password
```

## 密钥结构

| 路径 | 说明 | 使用位置 |
|------|------|----------|
| `misty/hashed_password` | 用户密码哈希 | `modules/nixos/base/users.nix` → `hashedPasswordFile` |
| `ssh/authorized_keys` | SSH 公钥列表 | `modules/nixos/base/users.nix` → `openssh.authorizedKeys` |

## 添加新密钥

1. `sops secrets/secrets.yaml` 编辑文件，添加新的 key
2. 在 `modules/nixos/base/sops.nix` 的 `sops.secrets` 中注册
3. 在需要使用的模块中通过 `config.sops.secrets."key/path".path` 引用

## 安全注意事项

- **age 私钥（`keys.txt`）绝对不能提交到 git**（已在 `.gitignore` 中排除）
- **sops 解密后的明文文件**不要保存在仓库目录中
- 加密后的 `secrets.yaml` 可以安全提交到 git（只有持有 age 私钥的机器才能解密）
- 多台主机可共享同一个 age 密钥对，或为每台主机生成独立密钥对（在 `.sops.yaml` 中添加多个 age 公钥）
