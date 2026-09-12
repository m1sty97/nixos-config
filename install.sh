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
# 注意：ISO tty 通常无中文环境，面向用户的提示信息使用英文。
# =============================================================================
set -euo pipefail

host=${1:?Usage: sudo ./install.sh <hostname>}
cd "$(dirname "$0")"

# sudo 切换到 root 后，libgit2 会因仓库属主不同而拒绝打开
# （safe.directory 检查），将仓库路径加入 root 的信任列表
repo_dir=$(pwd)
sudo git config --global --get-all safe.directory 2>/dev/null | grep -qxF "$repo_dir" || \
  sudo git config --global --add safe.directory "$repo_dir"

[ -f "hosts/${host}/disko.nix" ] || {
  echo "Error: hosts/${host}/disko.nix not found"
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
  echo "Error: age private key not found (sops needs it to decrypt passwords and pubkeys)"
  echo "Generate and place one first: age-keygen -o ~/.config/sops/age/keys.txt"
  exit 1
fi
echo "Using age key: ${key_src}"

# ---------------------------------------------------------------------------
# 磁盘确认与清盘二次确认
# ---------------------------------------------------------------------------
device=$(sed -n 's/.*diskDevice = "\([^"]*\)".*/\1/p' "hosts/${host}/disko.nix" | head -1)
echo
echo "Host: ${host}"
echo "Disk: ${device:-diskDevice not found in disko.nix, verify manually!}"
lsblk
echo
echo "WARNING: ALL data on the disk (${device:-?}) will be wiped!"
read -r -p "Type 'yes' to continue: " confirm
[ "$confirm" = "yes" ] || { echo "Aborted."; exit 1; }

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
echo "Install complete. Reboot."
