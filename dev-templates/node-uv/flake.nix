# node-uv 模板 — Node.js LTS + pnpm + uv
# 使用：复制本目录到项目根（或 nix develop 引用），进入后 node/pnpm/uv 即用
# 包管理：Node 侧用 pnpm（registry 走 npmmirror 国内镜像，shellHook 已声明）
{
  description = "Node.js (LTS) + pnpm + uv development environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          nodejs_24
          pnpm
          uv
        ];

        # 依赖镜像（新增环境须同步镜像配置，见 dev-templates/README.md）
        shellHook = ''
          export NPM_CONFIG_REGISTRY="https://registry.npmmirror.com"
        '';
      };
    };
}
