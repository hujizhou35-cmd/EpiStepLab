# 取得并使用 EpiStepLab

[English](../guides/installation.md) | **简体中文** · [首页](README.md)

## 选择下载

| 文件 | 用途 |
|---|---|
| `episteplab-v1.0.0.skill` | ZIP 容器，包含完整技能目录与 MIT 许可 |
| `episteplab-codex-plugin-v1.0.0.zip` | 同一完整技能的轻量 Codex Plugin 包装 |
| `SKILL.md` | 阅读或预览主体，不含参考文件和模板 |

[进入该版 Release](https://github.com/hujizhou35-cmd/EpiStepLab/releases/tag/v1.0.0)。GitHub 自动生成的 Source code ZIP/TAR 是标签对应的整个公开仓库，含文档和开发材料，不是额外的安装版本。

## 完整技能：最直接的使用方式

将 `.skill` 作为 ZIP 解包。如果解压工具只识别 `.zip`，复制一份并修改副本扩展名。完整保留 `episteplab/` 文件夹，让能读取本地文件的 AI 加载其中的 `SKILL.md`，并按需读取其引用资源；不要只复制一个 Markdown 文件。

若宿主支持项目技能发现，按它的当前官方说明放入项目目录。Codex 当前文档给出的项目级位置是 `.agents/skills/episteplab/`。不同平台的导入和发现机制有区别，`.skill` 扩展名不代表所有平台都能直接导入。

## Codex Plugin 方式

将 Plugin ZIP 解包到选定项目，例如 `plugins/episteplab/`。插件根目录包含 `.codex-plugin/plugin.json`、`skills/episteplab/` 和展示资源。按宿主当前官方本地插件说明配置。在 `.agents/plugins/marketplace.json` 使用以下完整示例（路径相对项目根目录）：

```json
{
  "name": "episteplab-local",
  "plugins": [{
    "name": "episteplab",
    "source": {"source": "local", "path": "./plugins/episteplab"},
    "interface": {"displayName": "EpiStepLab"},
    "policy": {"installation": "AVAILABLE", "authentication": "ON_INSTALL"},
    "category": "Productivity"
  }]
}
```

按官方说明刷新或重启后，在受支持的界面选择本地来源。此处仅分发包装文件，未向插件目录提交审核；没有新增 MCP、账号、后台或研究功能。公开检查核对结构与文件，不等于所有宿主的安装界面都已实测。[完整配置示例](../guides/installation.md#codex-plugin-route)

## 环境与版本

宿主需要读取本地资源的能力；执行需要 R；检索需要联网工具；查看实际图像需要相应查看能力。全文权限和数据库访问许可由使用者自行具备。两个 R 模板使用 base R；具体方法可能需要额外包，应讨论并记录。

现有技术记录使用 Windows 11、R 4.4.2，这是已测试环境，不是最低版本要求。其他操作系统、平台集成、自动触发、英文行为与 RStudio GUI 尚未全面验证。

两版都使用 `episteplab` 标识，一次只加载一版。技能资源保留中文原件。开发区测试工具用于模拟技术检查，不是实际研究的一键分析入口。

格式依据：[OpenAI 技能](https://learn.chatgpt.com/docs/build-skills)、[OpenAI 插件包装](https://developers.openai.com/plugins/build/plugins)、[Claude ZIP 目录](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills)。文档支持某种格式不等于本项目已验证对应平台兼容。
