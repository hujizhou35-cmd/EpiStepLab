# Start a study

[English](quickstart.md) | [简体中文](../zh-CN/quickstart.md) · [Home](../../README.md)

1. Read [research preparation](research-preparation.md), then [get the complete skill](installation.md).
2. In your AI host, explicitly select EpiStepLab v1.1.0, or ask it to read the extracted `episteplab/SKILL.md` and its referenced files. Supply your study directory, permitted output directory, data availability, dictionaries, and current question.
3. Discuss the actual current step. Confirm its inputs, definitions, choices, and checks. The AI then saves ordinary R code, reviews it, runs it in a fresh R session where appropriate, inspects outputs, reports, and stops for the next discussion.

```text
Use EpiStepLab. My topic is [topic]. My data and dictionary are in [path].
You may write to [directory]. First inspect what is available and explain
the definitions and decisions that remain unclear. Discuss methods that
fit the question and data. Do not generate the whole analysis in advance.
Only implement the current step after I confirm it.
```

Agreeing to a broad route does not confirm every later step. A template's stop statement must not be bypassed to simulate a researcher's confirmation. For heavy computation, prepare the current code and resource notes and discuss execution separately.

The runtime resources are Chinese; the English prompt is a translated usage aid, not evidence of tested English behavior. If data are unavailable, discuss preparation and evidence that do not require them. [Resuming](resuming.md) explains how to return to existing work.
