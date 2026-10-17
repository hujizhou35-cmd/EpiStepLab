# 模拟技术检查

[English](README.md) | **简体中文**

开发运行器编排独立模拟技术测试，不是研究使用者的分析入口。不使用真实数据、AI 服务，不全局安装技能或 R 包。

原测试的公开复跑方式支持 Windows 和可用的 Rscript，历史环境为 R 4.4.2。新启动器需要 Python 3.10+，只用标准库。选择当前检出目录内 `.test-runs/` 下全新目录：

```text
python development/tests/run_synthetic.py --version 1.0.0 --rscript Rscript.exe --output .test-runs/v1-run-01
python development/tests/run_synthetic.py --version 1.1.0 --rscript Rscript.exe --output .test-runs/v11-run-01
```

Rscript 不在 PATH 时传入现有程序的完整路径。启动器将临时文件留在运行目录，仅向子进程传递环境设置，拒绝已有输出目录；必要时用临时 Windows 盘符避开空格，最后恢复映射。R 源码、参数和预期保持原字节，新启动器只调整路径与准备方式。

两套测试分别运行：旧版 17 场景；新版 11 个进程场景和 26 项数值核查。两个版本模板相同，旧测试启动前仍按旧版清单核对所用模板哈希。正常和拒绝场景都需符合预期，失败与结果保存在指定目录。

这些检查不重跑 AI 行为演练、BKMR、真实研究或其他方法。[验证限制](../../docs/validation/README.zh-CN.md)。
