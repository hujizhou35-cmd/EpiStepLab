# 独立单步场景的测试调度器；仅技术测试，不是研究全流程生成器。
# 每个场景在新的 R --vanilla 进程运行，所有实际文件和临时目录须位于本 workspace。
参数 <- commandArgs(trailingOnly = TRUE)
if (length(参数) != 1L) stop("请提供真实 workspace 绝对路径。")
根目录 <- normalizePath(参数[1L], winslash = "/", mustWork = TRUE)
技术目录 <- file.path(根目录, "validation", "technical")
输出根 <- file.path(技术目录, "outputs")
if (dir.exists(输出根)) stop("已有技术输出，不自动覆盖；请核实并另存旧测试后再运行。")
dir.create(输出根)
source(file.path(根目录, "episteplab", "assets", "templates", "本步工具.R"), encoding = "UTF-8")
R入口 <- file.path(R.home("bin"), "Rscript.exe")
结果 <- list()

准备场景 <- function(名称, 场景 = 名称) {
  目录 <- file.path(输出根, 名称)
  dir.create(目录)
  file.copy(file.path(根目录, "episteplab", "assets", "templates", "本步工具.R"), 目录)
  file.copy(file.path(技术目录, "模拟单步.R"), 目录)
  # 【已确认】仅本次已授权技术验收的固定模拟参数，绝不作为真实研究默认值。
  set.seed(20261017L)
  数据 <- data.frame(id = sprintf("S%03d", seq_len(80)), wave = 1L,
                    x = rnorm(80), y = numeric(80))
  数据$y <- 2 + 0.8 * 数据$x + rnorm(80, sd = 1.1)
  if (场景 == "missing_field") 数据$x <- NULL
  if (场景 == "duplicate_key") 数据$id[2L] <- 数据$id[1L]
  if (场景 == "missing_key") 数据$id[2L] <- NA_character_
  if (场景 == "blank_key") 数据$id[2L] <- "  "
  if (场景 %in% c("compound_ok", "compound_duplicate")) {
    数据$id[2L] <- 数据$id[1L]
    数据$wave[2L] <- if (场景 == "compound_ok") 2L else 1L
  }
  write.csv(数据, file.path(目录, "输入_模拟数据.csv"), row.names = FALSE)
  writeLines(场景, file.path(目录, "场景.txt"), useBytes = TRUE)
  writeLines(c("# 本步说明：仅模拟技术验收", "全部数据是新建模拟数据，非 NHANES。",
               "确认依据：使用者已请求实施计划中的模拟验收；本目录只是独立单步测试。",
               "当前方法：普通 lm 验文件与数值一致，不做真实医学解释。",
               "运行入口：Rscript --vanilla 模拟单步.R；到此停止，无下一步入口。"),
             file.path(目录, "本步说明.md"), useBytes = TRUE)
  write.csv(记录文件指纹(目录, c("输入_模拟数据.csv", "场景.txt")),
            file.path(目录, "输入指纹.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  if (场景 == "input_changed") cat("\n", file = file.path(目录, "输入_模拟数据.csv"), append = TRUE)
  if (场景 == "existing_output") writeLines("earlier result", file.path(目录, "输出_系数表.csv"))
  if (场景 == "missing_input") unlink(file.path(目录, "输入_模拟数据.csv"))
  目录
}

测试进程 <- function(名称, 目录, 预期退出 = 0L, 预期提示 = NULL, 入口 = "模拟单步.R") {
  日志 <- file.path(输出根, paste0(名称, "_进程日志.txt"))
  # 系统命令只启动 R，不拼接任何可执行研究参数。
  状态 <- suppressWarnings(system2(R入口, c("--vanilla", shQuote(file.path(目录, 入口))),
                                  stdout = 日志, stderr = 日志, wait = TRUE))
  文本 <- paste(readLines(日志, encoding = "UTF-8", warn = FALSE), collapse = "\n")
  通过 <- identical(as.integer(状态), as.integer(预期退出)) &&
    (is.null(预期提示) || grepl(预期提示, 文本, fixed = TRUE))
  if (预期退出 == 0L) {
    必需输出 <- c("输出_系数表.csv", "输出_绘图数据.csv", "输出_模型.rds", "输出_拟合图.png",
                  "检查_运行环境.txt", "检查_运行指纹.csv", "运行日志.txt", "检查_样本变化.csv")
    通过 <- 通过 && all(file.exists(file.path(目录, 必需输出))) &&
      file.info(file.path(目录, "输出_拟合图.png"))$size > 1000
  }
  结果[[length(结果) + 1L]] <<- data.frame(场景 = 名称, 实际退出码 = 状态,
                                          预期退出码 = 预期退出, 通过 = 通过,
                                          预期提示 = if (is.null(预期提示)) "成功并带齐输出" else 预期提示,
                                          stringsAsFactors = FALSE)
  cat(名称, ": ", if (通过) "PASS" else "FAIL", "\n", sep = "")
}

测试进程("01_中文含空格路径_正常", 准备场景("01_中文含空格路径_正常", "normal"))
测试进程("02_缺少字段", 准备场景("02_缺少字段", "missing_field"), 1L, "缺少必需字段")
测试进程("03_重复键", 准备场景("03_重复键", "duplicate_key"), 1L, "连接键不唯一")
测试进程("04_缺失键", 准备场景("04_缺失键", "missing_key"), 1L, "连接键存在缺失")
测试进程("05_输入改动", 准备场景("05_输入改动", "input_changed"), 1L, "文件指纹已变化")
测试进程("06_模型表改动", 准备场景("06_模型表改动", "table_mismatch"), 1L, "模型表 estimate数值与正式结果不一致")
测试进程("07_绘图数值改动", 准备场景("07_绘图数值改动", "plot_mismatch"), 1L, "绘图数值与正式结果不一致")
测试进程("08_复合键正确", 准备场景("08_复合键正确", "compound_ok"))
测试进程("09_复合键重复", 准备场景("09_复合键重复", "compound_duplicate"), 1L, "连接键不唯一")
移动前 <- 准备场景("搬移前_此目录将不存在", "normal")
移动后 <- file.path(输出根, "10_搬移后_独立一步")
if (!file.rename(移动前, 移动后)) stop("无法搬移模拟步骤。")
测试进程("10_搬移后_独立一步", 移动后)
模板目录 <- file.path(输出根, "11_模板默认阻止")
dir.create(模板目录)
file.copy(file.path(根目录, "episteplab", "assets", "templates", c("本步工具.R", "单步分析.R")), 模板目录)
测试进程("11_模板默认阻止", 模板目录, 1L, "模板默认停止", "单步分析.R")
来源目录 <- 准备场景("12_source从其他目录调用", "normal")
# 使用 ASCII 码转义构造 R 字面量，避免测试包装脚本依赖 shell 转义。
引号路径 <- encodeString(file.path(来源目录, "模拟单步.R"), quote = '"')
包装入口 <- file.path(输出根, "12_source包装入口.R")
writeLines(paste0("source(", 引号路径, ", encoding=\"UTF-8\")"), 包装入口, useBytes = TRUE)
测试进程("12_source从其他目录调用", 来源目录, 0L, NULL,
           file.path("..", "12_source包装入口.R"))
测试进程("13_空白键", 准备场景("13_空白键", "blank_key"), 1L, "连接键存在缺失或空白")
测试进程("14_已有输出", 准备场景("14_已有输出", "existing_output"), 1L, "已有输出不能自动覆盖")
测试进程("15_缺少完整输入", 准备场景("15_缺少完整输入", "missing_input"), 1L, "输入或脚本文件不存在")
测试进程("16_输出与输入重名", 准备场景("16_输出与输入重名", "output_same_input"), 1L, "输出文件重名或与输入重名")
模板来源 <- file.path(输出根, "17_source模板默认阻止")
dir.create(模板来源)
file.copy(file.path(根目录, "episteplab", "assets", "templates", c("本步工具.R", "单步分析.R")), 模板来源)
writeLines(paste0("source(", encodeString(file.path(模板来源, "单步分析.R"), quote = '"'),
                 ", encoding=\"UTF-8\")"), file.path(输出根, "17_source模板包装.R"), useBytes = TRUE)
测试进程("17_source模板默认阻止", 模板来源, 1L, "模板默认停止", file.path("..", "17_source模板包装.R"))

汇总 <- do.call(rbind, 结果)
write.csv(汇总, file.path(技术目录, "technical_results.csv"), row.names = FALSE, fileEncoding = "UTF-8")
保存运行环境(技术目录, "technical_sessionInfo.txt")
cat("总计：", nrow(汇总), "；通过：", sum(汇总$通过), "\n", sep = "")
if (!all(汇总$通过)) quit(status = 1L)
