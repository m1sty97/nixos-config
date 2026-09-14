# =============================================================================
# hosts/misty-server/ai/hermes.nix — Hermes Agent(个人 AI 助理,系统服务)
# -----------------------------------------------------------------------------
# Nous Research hermes-agent,官方 NixOS 系统服务模块形态(官方推荐的共享模式):
#   - 7×24 常驻助理,Web dashboard 供 Windows/手机局域网访问(端口 9119,
#     绑定 0.0.0.0 激活鉴权门)
#   - 模型:DeepSeek API(deepseek-flash,OpenAI 兼容)
#   - API key 经 sops 注入 environmentFiles(切勿写入 settings/store)
#   - 服务以模块自动创建的非特权专用用户 hermes 运行(createUser 默认开,
#     home=/var/lib/hermes),运维经 sudo systemctl 操作服务单元
#   - addToSystemPackages:CLI 进系统 PATH 且 HERMES_HOME 全局导出,交互用户
#     与服务共享 sessions/skills/cron(官方警告:不开此项,shell 里的 hermes
#     会另建 ~/.hermes 分叉状态)
#   - 共享状态的文件权限是组权限(目录 2770/config.yaml 0660),普通用户须
#     加入 hermes 组(下方 extraGroups);注意该组成员可读服务 .env 中的密钥
# ⚠️ 本文件属于 misty-server 专属 AI 环境,勿移入 base/server 模块组或模板。
# 方案详见 docs/ai-dev-environment-design.md。
# =============================================================================
{
  inputs,
  config,
  myvars,
  ...
}:
{
  # 官方 NixOS 模块（flake input,见 flake.nix 的 hermes-agent）
  imports = [ inputs.hermes-agent.nixosModules.default ];

  # API key 等敏感环境变量经 sops 注入(激活时写入 HERMES_HOME/.env);
  # key 名用连字符扁平形式 hermes-env(官方文档约定):sops-nix 中斜杠会被
  # 解释为嵌套路径,扁平连字符命名可避免结构歧义,后续新凭据直接追加到该值
  sops.secrets."hermes-env" = { };

  services.hermes-agent = {
    enable = true;

    # CLI 进系统 PATH + HERMES_HOME 全局导出(官方共享状态模式,
    # misty 无需独立 CLI 安装)
    addToSystemPackages = true;

    # 模型:DeepSeek API(OpenAI 兼容,flash 档)
    settings.model = {
      provider = "deepseek";
      default = "deepseek-flash";
      base_url = "https://api.deepseek.com/v1";
    };

    # Web dashboard — 绑定 0.0.0.0 激活鉴权门,局域网(Windows/手机)访问;
    # 绑 0.0.0.0 时防 DNS rebinding 的 Host 头校验对任意 Host 放行
    backend = {
      mode = "dashboard";
      host = "0.0.0.0";
      port = 9119;
    };

    # 敏感环境变量文件(sops 解密,激活时合并进 $HERMES_HOME/.env)
    environmentFiles = [
      config.sops.secrets."hermes-env".path
    ];

    # 阶段 4/5 预留:共享记忆(Hindsight)与知识库(LightRAG)经
    # settings.mcpServers 接入,届时在此追加
    mcpServers = {

    };
  };

  # 普通用户接入共享状态:目录 2770/config.yaml 0660 均为 hermes 组权限,
  # misty 须入组才能读写(原生模式模块不自动加组,容器模式的 hostUsers 才会)
  users.users.${myvars.username}.extraGroups = [ "hermes" ];
}
