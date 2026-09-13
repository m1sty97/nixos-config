# python-uv 模板 — Python 3 + uv
# 使用：复制本目录到项目根（或 nix develop 引用），进入后 python/uv 即用
# 项目依赖与虚拟环境由 uv 管理（uv init / uv add / uv sync），
# PyPI 索引走 CERNET 镜像（shellHook 已声明）
{
  description = "Python 3 + uv development environment";

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
          python3
          uv
        ];

        # 依赖镜像（新增环境须同步镜像配置，见 dev-templates/README.md）
        shellHook = ''
          export UV_DEFAULT_INDEX="https://mirrors.cernet.edu.cn/pypi/simple"
        '';
      };
    };
}
