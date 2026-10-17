# Synthetic technical checks

**English** | [简体中文](README.zh-CN.md)

These development runners orchestrate independent synthetic checks. They are not research analysis entrypoints. No real data, AI service, global skill install, or package install is used.

Windows with an available Rscript is the supported rerun route for the original tests. The original evidence used R 4.4.2. Python 3.10+ is needed for the new launcher; its standard library is sufficient. Choose a fresh run directory inside your checkout's ignored `.test-runs/` folder:

```text
python development/tests/run_synthetic.py --version 1.0.0 --rscript Rscript.exe --output .test-runs/v1-run-01
python development/tests/run_synthetic.py --version 1.1.0 --rscript Rscript.exe --output .test-runs/v11-run-01
```

Pass the full path to an existing Rscript if it is not on PATH. The launcher keeps temporary files inside that run directory, passes temporary settings only to child processes, refuses existing output directories, and restores a temporary Windows drive mapping if needed to avoid spaces. Runtime R sources retain original bytes, parameters and expectations. The launcher changes path/staging only.

v1.0.0 runs 17 scenarios with fresh R subprocesses. v1.1.0 runs 11 process scenarios and the 26-item numeric audit. Run those suites separately. The current templates are byte-identical between versions; the v1.0.0 staging check verifies the required template hashes against its own manifest before execution. Both positive and refusal scenarios must match expectations. Results and failures remain in the selected output directory.

These checks do not rerun AI behavior rehearsals, BKMR, real studies, or other methods. Read [validation limits](../../docs/validation/README.md).
