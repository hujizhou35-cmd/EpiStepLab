# Prepare your research

[English](research-preparation.md) | [简体中文](../zh-CN/research-preparation.md) · [Home](../../README.md)

Before starting, consider a detailed discussion with another AI. Try to understand:

- Your exposure and outcome, including their components and timing.
- The formula, units, required variables, and missing-value rules for each indicator.
- The question you want to answer and what different methods could tell you.

```text
I want to study [question] using [database/version]. Help me understand
the exposure and outcome, indicator components, formulas, units, and required
variables. Find original definitions and application studies with verifiable
PMID/DOI identifiers and source locations. Explain suitable methods, their
assumptions, and unresolved questions. Do not generate the full analysis code.
```

This is preparation advice, not an entry requirement or a request for proof of another conversation. Other AI answers are leads to verify.

In v1.1.0, EpiStepLab checks original definitions and relevant application studies; records available PMID, DOI or other stable identifiers, formulas, units, source locations, access level, and local field mappings; and discusses conflicting definitions or missing components before deriving an indicator. An inaccessible full text remains an evidence gap. Do not invent identifiers, replace unavailable components with zero, or treat a proxy as the original measure.

v1.0.0 provides the earlier data, field, and study-design workflow; the explicit provenance and method-discovery resources were added in v1.1.0.
