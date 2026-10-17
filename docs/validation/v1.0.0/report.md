# v1.0.0 validation report

[English](report.md) | [简体中文](report.zh-CN.md) · [Validation index](../README.md)

Original validation date: 2026-10-17. This publication report summarizes the preserved Chinese local report; it is not a replacement for its original bytes. All analysis fixtures were synthetic. Historical research projects were read-only references and were not executed.

## Format and technical execution

The [standard format check](evidence/skill-format.txt) passed. Eight local structure checks covered identity, UI metadata, resource presence, internal links, and caches. The runtime contains 14 files: the entrypoint, UI metadata, 5 references, and 7 templates. See the [runtime source manifest](../../provenance/runtime-v1.0.0.json).

All [17 technical subprocess scenarios](evidence/technical-results.csv) matched expectations. They covered Chinese/space-containing paths, fresh R sessions, moving a complete step, source invocation from another directory, missing fields or inputs, duplicate/missing/blank/composite keys, changed fingerprints, refusal to overwrite outputs, input/output name collisions, changed model tables or plot data, and unconfirmed template stops. Expected errors are successful safeguards, not successful analyses.

The check helper's model-table comparison covers ordinary `lm` only. Plot-data agreement does not establish numeric correctness from pixels. Existing technical execution used Windows 11 and R 4.4.2, with base R.

## Nine behavior scenario types

| Scenario | Author-reviewed outcome |
|---|---|
| No local data | Discussed preparation or verified access; no analysis script |
| Unclear fields | Preserved special missing values and asked about coding, units, waves, and population |
| Imputation decision | Initially omitted a sensitivity-analysis reminder; skill strengthened and a fresh scenario retest included it |
| Broad route agreed | Asked about unresolved age, missingness, and thresholds instead of writing all later steps |
| Current baseline step confirmed | Saved complete inputs, a baseline table, CSV and PNG; stopped before regression |
| Resume with changed input | Recomputed MD5, detected changed input and AI-written confirmation; preserved prior results |
| BKMR details missing | Asked for exposures, parameters, and resources; no assumed run |
| MR request | Explained the boundary and did not perform MR |
| BKMR code preparation | Prepared code, inputs, dependencies and resource notes; parsed code and checked interfaces without sampling |

Rehearsal agents read the skill and original scenarios without the author's grading criteria or other outputs. The author reviewed replies, saved files, and action notes. This was not automated semantic scoring, a no-skill control experiment, strict double-blind evaluation, or a cross-model benchmark. Original scenario and action records remain local.

## Actual baseline checks and retained failures

The baseline used 24 simulated records, 12 in each group. Age denominators were 11/12, means 46.6363636363636/58.5, and sample SDs 3.74893924391226/3.60555127546399. Age and sex missingness were neither imputed nor used to drop records. Read-back CSV values agreed with independent sums and squared-deviation calculations.

A moved copy ran in a fresh R process with exit 0; four CSV files were byte-identical. An initial wrapper restoration check failed because an absent temporary-directory environment variable became an empty string; the launcher was repaired and restoration rechecked. The extra strict PNG hash comparison still exited 1: both file hashes and decoded pixels differed for an unresolved reason. Both actual PNGs were visually inspected and the plot-data CSVs agreed. Pixel-identical figure reproduction is **not** claimed; the wrapper failure remains a failure record.

The initial R environment rejected a temporary path containing spaces; the original launcher used a temporary drive alias within the workspace and restored mappings/environment. Original failed rounds and logs remain local.

## Not validated

Real NHANES, CHARLS, CLHLS, or ELSA extraction, field mapping and research; complex survey/longitudinal inference; imputation, WQS/qgcomp, RCS, mediation, survival, machine learning and external validation across real studies; BKMR sampling, convergence, resource demand, or server migration; automatic triggering; other AI/OS compatibility; actual RStudio GUI operation; Word/PDF/TIFF research delivery; pixel-level reproduction; scientific validity, publication readiness, or final user acceptance.

These method resources are discussion guides, not evidence that every method was run. Publication packaging and technical reruns are separate checks; no original behavior rehearsal was repeated for publication.
