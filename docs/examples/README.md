# A simulated step

**English** | [简体中文](README.zh-CN.md) · [Home](../../README.md)

**All records are simulated, not NHANES or another real database.** This is one recorded technical fixture step, not a real study or a recommended analysis recipe.

The 80 simulated records came from a fixed technical fixture. Ordinary `lm` was used to check input, model-table and plot-data handoff; its parameters are not research defaults.

- [Complete simulated input](simulated-lm/输入_模拟数据.csv)
- [Actual coefficient table](simulated-lm/输出_系数表.csv)
- [Underlying plot data](simulated-lm/输出_绘图数据.csv)
- [Independent synthetic technical sources](../../development/tests/README.md)

![Actual technical-test plot from a simulated ordinary linear model](simulated-lm/输出_拟合图.png)

This page displays inputs and outputs; reruns use the development fixtures, with no private author data. The generation and checking logic is in those sources. Passing technical checks establishes neither medical validity nor authorization for real research.
