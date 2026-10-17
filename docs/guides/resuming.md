# Resume existing work

[English](resuming.md) | [简体中文](../zh-CN/resuming.md) · [Home](../../README.md)

Provide the same selected skill version, study folder, recent decisions, and the step you want to resume. Ask the AI to inspect files, inputs, code, and actual outputs before treating prior status as current.

```text
Resume this study with EpiStepLab [version]. Inspect [directory] and my
recorded decisions. I want to return to [step]. Identify what is reusable,
what changed, and what needs checking. Explain unresolved choices before
implementing the current step. Preserve earlier outputs.
```

v1.1.0 also reviews the prior method-search record and checks relevant developments since that search. Missing queries, unavailable sources, or tools must be disclosed; a new paper does not automatically replace an agreed method.

Changed inputs or code mean dependent outputs need review. An AI-written status or confirmation is not a new user decision. Each current step must carry its complete actual inputs and run independently of an old R session.
