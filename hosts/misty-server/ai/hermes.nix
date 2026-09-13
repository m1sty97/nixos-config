# =============================================================================
# hosts/misty-server/ai/hermes.nix — Hermes Agent(个人 AI 助理)
# -----------------------------------------------------------------------------
# Nous Research hermes-agent,官方 NixOS 系统服务模块形态:
#   - 7×24 常驻助理,Web dashboard 供 Windows/手机局域网访问(端口 9119,
#     绑定 0.0.0.0 激活鉴权门)
#   - 模型:DeepSeek API(deepseek-flash,OpenAI 兼容)
#   - API key 经 sops 注入 environmentFiles(切勿写入 settings/store)
#   - addToSystemPackages:hermes CLI 进系统 PATH,供 SSH 使用,
#     并为 hermes → dsh 委派链路预留
# ⚠️ 本文件属于 misty-server 专属 AI 环境,勿移入 base/server 模块组或模板。
# 方案详见 docs/ai-dev-environment-design.md。
# =============================================================================
{
  inputs,
  config,
  ...
}:
{
  # 官方 NixOS 模块（flake input,见 flake.nix 的 hermes-agent）
  imports = [ inputs.hermes-agent.nixosModules.default ];

  # API key 等敏感环境变量经 sops 注入(激活时写入 HERMES_HOME/.env);
  # 内容为多行 KEY=VALUE,后续 hermes 新凭据直接追加到该值即可
  sops.secrets."hermes/env" = { };

  services.hermes-agent = {
    enable = true;

    # CLI 进系统 PATH(SSH 手动使用;委派链路 hermes → dsh 也走 PATH)
    addToSystemPackages = true;

    # 模型:DeepSeek API(OpenAI 兼容,flash 档;base_url 官方即根路径,不带 /v1)
    settings.model = {
      default = "deepseek-flash";
      base_url = "https://api.deepseek.com";
    };

    # Web dashboard — 绑定 0.0.0.0 激活鉴权门,局域网(Windows/手机)访问
    backend = {
      mode = "dashboard";
      host = "0.0.0.0";
      port = 9119;
    };

    # 敏感环境变量文件(sops 解密,systemd EnvironmentFile 格式)
    environmentFiles = [
      config.sops.secrets."hermes/env".path
    ];

    # 阶段 4/5 预留:共享记忆(Hindsight)与知识库(LightRAG)经
    # settings.mcpServers.<name> 接入,届时在此追加
  };
}
