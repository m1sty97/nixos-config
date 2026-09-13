# node-uv 模板 — Node.js LTS + uv
# 使用：复制本目录到项目根（或 nix develop 引用），进入后 node/npm/npx/uv 即用
{
  description = "Node.js (LTS) + uv development environment";

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
          uv
        ];
      };
    };
}
