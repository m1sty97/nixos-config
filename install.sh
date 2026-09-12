#!/usr/bin/env bash
# =============================================================================
# install.sh — NixOS 首次安装/重装一键脚本（在 NixOS ISO 环境执行）
# -----------------------------------------------------------------------------
# 用法：sudo ./install.sh <主机名>
#   例如：sudo ./install.sh misty-server
#
# 流程：临时启用 Flakes → disko 清盘分区 → 部署 age 私钥 → nixos-install
# ⚠️ 会清空 hosts/<主机名>/disko.nix 中 diskDevice 指向的磁盘，
#    执行前务必确认设备名并完成数据备份！
# =============================================================================
set -euo pipefail

host=${1:?用法: sudo ./install.sh <主机名>}
cd "$(dirname "$0")"

[ -f "hosts/${host}/disko.nix" ] || {
  echo "错误: hosts/${host}/disko.nix 不存在"
  exit 1
}

# ISO 环境默认未启用 Flakes（sudo 会丢弃环境变量，故 sudo 调用时显式传参）
NIX_CONFIG="experimental-features = nix-command flakes"
export NIX_CONFIG
nix_flags=(--extra-experimental-features "nix-command flakes")

# ---------------------------------------------------------------------------
# 定位 age 私钥：显式环境变量 → 当前用户 → sudo 前的用户（ISO 上为 nixos）
# ---------------------------------------------------------------------------
key_candidates=(
  "${SOPS_AGE_KEY_FILE:-}"
  "${HOME}/.config/sops/age/keys.txt"
  "/home/${SUDO_USER:-nixos}/.config/sops/age/keys.txt"
)
key_src=""
for k in "${key_candidates[@]}"; do
  if [ -n "$k" ] && [ -f "$k" ]; then
    key_src="$k"
    break
  fi
done
if [ -z "$key_src" ]; then
  echo "错误: 未找到 age 私钥（sops 解密密码与公钥依赖它）"
  echo "请先生成并放置: age-keygen -o ~/.config/sops/age/keys.txt"
  exit 1
fi
echo "使用 age 私钥: ${key_src}"

# ---------------------------------------------------------------------------
# 磁盘确认与清盘二次确认
# ---------------------------------------------------------------------------
device=$(sed -n 's/.*diskDevice = "\([^"]*\)".*/\1/p' "hosts/${host}/disko.nix" | head -1)
echo
echo "主机: ${host}"
echo "磁盘: ${device:-未在 disko.nix 中找到 diskDevice，请人工确认！}"
lsblk
echo
echo "⚠️  上述磁盘（${device:-?}）上的全部数据将被清空！"
read -r -p "确认继续请输入 yes: " confirm
[ "$confirm" = "yes" ] || { echo "已取消"; exit 1; }

# ---------------------------------------------------------------------------
# 分区 + 格式化 + 挂载 /mnt（disko 版本随 flake.lock 锁定）
# ---------------------------------------------------------------------------
sudo nix "${nix_flags[@]}" run ".#disko" -- --mode destroy,format,mount "hosts/${host}/disko.nix"

# ---------------------------------------------------------------------------
# 部署 age 私钥（首次开机 sops 解密用户密码与 SSH 公钥的依赖）
# ---------------------------------------------------------------------------
sudo mkdir -p /mnt/var/lib/sops-nix/age
sudo cp "$key_src" /mnt/var/lib/sops-nix/age/keys.txt
sudo chmod 600 /mnt/var/lib/sops-nix/age/keys.txt

# ---------------------------------------------------------------------------
# 安装
# ---------------------------------------------------------------------------
sudo env NIX_CONFIG="$NIX_CONFIG" nixos-install --flake ".#${host}" --no-root-password

echo
echo "安装完成。重启后请："
echo "  1. 确认 /var/lib/sops-nix/age/keys.txt 存在（脚本已部署）"
echo "  2. 立即修改 misty 密码（历史哈希曾在仓库中暴露）"
echo "  3. 如在装好的系统上改配置，直接 git pull 后 nixos-rebuild switch 即可"
