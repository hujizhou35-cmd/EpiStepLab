# v1.1.0 validation report

[English](report.md) | [简体中文](report.zh-CN.md) · [Validation index](../README.md)

Original validation date: 2026-10-17. This is a curated publication report from preserved local evidence. All new inputs were synthetic. No historical real-data research was executed, no global skill was installed, and original versions were preserved.

## Identity and structure

The upgrade checked 690 original files and the complete v1.0.0 archive against SHA-256 and file-set records. v1.1.0 contains 19 runtime files: the entrypoint, UI metadata, 8 references, and 9 templates. Both R templates are byte-identical to v1.0.0. Earlier 17-scenario evidence is not counted as new v1.1.0 method or behavior evidence.

The [standard format check](evidence/skill-format.txt) passed; 8 local checks covered version identity, UI, internal links, self-contained resources, template equality, caches, and original/archive preservation. Saved-artifact checks also covered records, restoration, independent rank calculation, six behavior records, absence of unrequested scripts, and handoff links. These are not automatic semantic judgments. See the [runtime manifest](../../provenance/runtime-v1.1.0.json).

## Actual synthetic method execution

The final valid run was attempt_03. All [11 process scenarios](evidence/process-checks.csv) matched expectations: 4 method steps succeeded and 7 exceptional/unconfirmed conditions refused to continue without analysis outputs. All [26 numeric checks](evidence/numeric-checks.csv) passed.

| Method | What was checked |
|---|---|
| Spearman | 30 simulated rows, 3 prespecified pairs; valid n=25/26/25; ties and missingness retained; average ranks, asymptotic P values, and Holm correction checked independently |
| PCA | 48 simulated rows, 4 continuous variables; scenario-specific centering/scaling; loadings, scores, variance, reconstruction, sign changes, rank deficiency, equal-eigenvalue subspaces |
| K-means | 60 simulated rows; scaling, multiple starts and k=3 were fixture decisions; centers, counts, sums of squares, saved objects/exports, label permutation |
| Hierarchical clustering | Complete local inputs; Euclidean/Ward.D2/k=3 were fixture decisions; merge heights, coassignment, counts, plot data |
| Refusals | Constant/missing PCA inputs, ordinary Spearman for survey inference, unconfirmed k, changed inputs, missing fields, and an unconfirmed method |

Numeric auditing also detected altered result tables and plot data. A separate Python average-rank calculation agreed for all three rho values and sample counts. Four actual final PNGs were independently opened by the method agent and the lead agent. Small-noise clustering ARI=1 reflects deliberately separated simulated groups and one selected perturbation, not bootstrap or external/clinical validation.

## Six AI behavior scenarios

| Scenario | Actual outcome and limit |
|---|---|
| Unclear indicator | Compared 3 TyG application studies; recorded identifiers, source positions and official field examples; discussed conflicting formula parentheses; original response full text remained unavailable; no derived-variable code |
| Open method choice | Proposed an ordered symptom-network candidate beyond the old cards; compared correlation, conditional association and factor goals; recorded 3 applications, methods and author software; no sampling |
| Resume | Detected an incomplete old search record; actually performed bounded searches; did not invent an incremental update or treat old AI advice as confirmation; disclosed malformed `site.` syntax and full-text gaps |
| No networking allowed | Used local material, stated that current searching was incomplete, and discussed supplying evidence or accepting a disclosed gap; did not fabricate citations |
| Simple question | Searched relevant correlation guidance; explained why PCA/clustering added little for the stated goal; retained unverified preprint/implementation limits; no calculation or analysis script |
| Execution boundaries | Broad agreement did not become full-pipeline code; imputation and sensitivity were discussed; no BKMR trial run or MR; unclear topic prompted questions |

Scenarios 01, 02 and 05 were rehearsed by agents that had written some references/templates, without the author's grading materials. Scenarios 03, 04 and 06 used fresh agents without inherited parent conversation. Those agents saved their materials before their turns ended due to quota; the lead agent read the actual files/actions rather than treating agent completion status as a pass. This is not strict double-blind, no-skill-control, or cross-model evaluation. Full original conversation/action records remain local.

The lead agent separately checked two TyG PubMed identifiers and the actual GitHub SHAs for two scenario-02 API records. Access restrictions, abstract/metadata-only reading, and unavailable versions remained disclosed. None of the six scenarios generated or ran research analysis scripts.

## Failures, corrections and environment

Attempt_01 failed because a fixture seed exceeded integer range. Attempt_02 passed numeric checks but clipped a Spearman label. Attempt_03 corrected the presentation; the formal result and plot-data CSV hashes before/after that visual fix matched. Pixel identity was not required or claimed.

The first delivery check incorrectly treated its not-yet-written output as a broken link. Its other six checks passed; checking order was repaired, with analysis code and numbers unchanged. Failed-attempt records remain local.

Runtime records showed R temporary files within the authorized workspace, restored environment and drive mappings, no user/system environment changes, and no global package installation. Existing execution used R 4.4.2; online development-version documentation was distinguished from the installed version. A repeated-run guard rejected an existing output directory and preserved its evidence.

## Not validated

Real database indicators, fields, weights, longitudinal inference, measurement validity or scientific validity; every method discussed in the guides (including networks, factor models, survey correlation/PCA/clustering, GAM, causal estimation, complex longitudinal models, WQS/qgcomp, imputation and prediction); systematic-review completeness or a universal newest/best method; access to all original texts/supplements/versions; all network-failure branches (the offline scenario was a user prohibition, not a manufactured outage); BKMR sampling/convergence/resources, server migration, MR; automatic triggering, comprehensive host/OS or English behavior compatibility, RStudio GUI, research publication figures, pixel reproduction or final user acceptance.

Publication technical reruns are separate from the original evidence. Guide coverage is not a claim that all listed methods were executed.
