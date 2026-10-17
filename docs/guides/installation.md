# Get and use EpiStepLab

[English](installation.md) | [简体中文](../zh-CN/installation.md) · [Home](../../README.md)

## Choose a download

| File | Purpose |
|---|---|
| `episteplab-v1.1.0.skill` | Complete skill folder and MIT license, in a ZIP container |
| `episteplab-codex-plugin-v1.1.0.zip` | The same complete skill in a lightweight Codex plugin container |
| `SKILL.md` | Read or preview the instructions; references and templates are absent |

[Open this release](https://github.com/hujizhou35-cmd/EpiStepLab/releases/tag/v1.1.0). GitHub's automatic **Source code** ZIP/TAR downloads contain the tagged repository, including documentation and development files; they are not additional installation editions.

## Complete skill: the simplest route

Extract the `.skill` as a ZIP container. If your extractor requires `.zip`, copy it and change the copy's extension. Keep the entire `episteplab/` folder together. Ask a file-capable AI host to read its `SKILL.md` and load referenced files as needed. Do not copy only the Markdown entrypoint.

For a host configured to discover project skills, place that whole folder in its documented project skill location. Codex currently documents `.agents/skills/episteplab/` for project-local discovery. Installation locations and import support differ by host. The `.skill` suffix is a distribution convention, not a promise of universal direct import.

## Codex plugin route

Unzip the plugin into a chosen project folder, for example `plugins/episteplab/`. Its root contains `.codex-plugin/plugin.json`, `skills/episteplab/`, and the presentation resources. Follow the current official local-plugin instructions for your host. A project-local marketplace can point to this folder; for a project containing that `plugins/` path, the catalog at `.agents/plugins/marketplace.json` can contain:

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

Restart or refresh as the official host instructions require, then select the local source if supported. This repository distributes a container; it has not been submitted to a plugin directory. No MCP service, credentials, backend, or new research feature is added. The publication checks validate structure and files, not every host's installation UI.

## Environment and version choice

The host must be able to read local resources. R execution requires an available R environment; method searches require network/search tools; actual visual checks require a viewer. Full-text access and database permissions remain the user's responsibility. The two R templates use base R; a chosen method may need additional packages, which must be discussed and recorded.

The existing technical tests used Windows 11 and R 4.4.2. This is a tested configuration, not a minimum-version claim. Other operating systems, host integrations, automatic triggering, English behavior, and real RStudio GUI operation are not comprehensively verified.

Both versions use the identifier `episteplab`. Load only one at a time. The runtime resources remain Chinese and retain their original bytes. Public test tools are optional development checks, not a research-analysis launcher.

Sources checked for packaging: [OpenAI skills](https://learn.chatgpt.com/docs/build-skills), [OpenAI plugin packaging](https://developers.openai.com/plugins/build/plugins), [Claude ZIP layout](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills). A documented format does not establish tested compatibility for this project.
