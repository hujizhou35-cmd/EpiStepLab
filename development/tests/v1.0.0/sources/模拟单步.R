# EpiStepLab 技术演练的一个独立步骤。全部数据为新建模拟数据，非 NHANES。
# 用户已授权本次模拟验收；下列方法和 seed 仅测试技术行为，不是研究默认参数。
# 完整输入、本脚本和本步工具.R 都在本步骤内，可搬移后运行。
定位本步目录 <- function() {
  来源 <- Filter(function(x) is.character(x) && length(x) == 1L && nzchar(x),
                 lapply(sys.frames(), function(x) x$ofile))
  参数 <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  候选 <- if (length(来源)) tail(来源, 1L)[[1L]] else if (length(参数)) {
    sub("^--file=", "", tail(参数, 1L))
  } else character()
  if (!length(候选) || !file.exists(候选)) stop("无法可靠定位；请 setwd 到本步后用 source 运行。")
  dirname(normalizePath(候选, winslash = "/", mustWork = TRUE))
}
本步目录 <- 定位本步目录()
source(file.path(本步目录, "本步工具.R"), local = TRUE, encoding = "UTF-8")

# 【已确认】仅技术演练，见本步说明.md；普通 lm 不代表任何真实研究适用性。
输入文件 <- c("输入_模拟数据.csv", "场景.txt")
场景 <- readLines(本步文件路径(本步目录, "场景.txt"), encoding = "UTF-8", warn = FALSE)
输出文件 <- c("输出_系数表.csv", "输出_绘图数据.csv", "输出_模型.rds", "输出_拟合图.png",
              "检查_运行环境.txt", "检查_运行指纹.csv", "运行日志.txt", "检查_样本变化.csv")

运行本步 <- function() {
  核对文件指纹(本步目录, read.csv(本步文件路径(本步目录, "输入指纹.csv"),
                                    check.names = FALSE, fileEncoding = "UTF-8"))
  if (identical(场景, "output_same_input")) 输出文件[1L] <- 输入文件[1L]
  检查输出文件(本步目录, 输出文件, c(输入文件, "模拟单步.R", "本步工具.R", "输入指纹.csv"))
  日志连接 <- file(本步文件路径(本步目录, "运行日志.txt"), "wt", encoding = "UTF-8")
  sink(日志连接, split = TRUE)
  on.exit({sink(); close(日志连接)}, add = TRUE)
  withCallingHandlers({
    # ==================== 1. 读取与核对 ====================
    cat("全部数据为技术验收模拟数据，非 NHANES；不产生真实研究结论。\n")
    保存运行环境(本步目录)
    write.csv(记录文件指纹(本步目录, c(输入文件, "模拟单步.R", "本步工具.R", "本步说明.md")),
              本步文件路径(本步目录, "检查_运行指纹.csv"), row.names = FALSE,
              fileEncoding = "UTF-8")
    本步数据 <- read.csv(本步文件路径(本步目录, "输入_模拟数据.csv"), check.names = FALSE)
    检查必需字段(本步数据, c("id", "wave", "x", "y"))
    键 <- if (场景 %in% c("compound_ok", "compound_duplicate")) c("id", "wave") else "id"
    检查连接键(本步数据, 键)
    if (anyNA(本步数据[, c("x", "y")])) stop("模拟输入 x/y 意外缺失，不自动删除或插补。")
    write.csv(data.frame(阶段 = c("读取", "建模"), 人数 = rep(nrow(本步数据), 2)),
              本步文件路径(本步目录, "检查_样本变化.csv"), row.names = FALSE,
              fileEncoding = "UTF-8")

    # ==================== 2. 模拟建模与保存 ====================
    模型 <- lm(y ~ x, data = 本步数据, na.action = na.fail)
    saveRDS(模型, 本步文件路径(本步目录, "输出_模型.rds"))
    系数 <- summary(模型)$coefficients
    结果表 <- data.frame(term = rownames(系数), estimate = 系数[, 1],
                         std_error = 系数[, 2], statistic = 系数[, 3], p_value = 系数[, 4],
                         row.names = NULL)
    if (identical(场景, "table_mismatch")) 结果表$estimate[2L] <- 结果表$estimate[2L] + 0.02
    write.csv(结果表, 本步文件路径(本步目录, "输出_系数表.csv"), row.names = FALSE)
    核对线性模型表(readRDS(本步文件路径(本步目录, "输出_模型.rds")),
                     read.csv(本步文件路径(本步目录, "输出_系数表.csv")))

    绘图数据 <- data.frame(x = seq(min(本步数据$x), max(本步数据$x), length.out = 80L))
    正式拟合 <- unname(predict(模型, newdata = 绘图数据))
    绘图数据$fit <- 正式拟合
    if (identical(场景, "plot_mismatch")) 绘图数据$fit[1L] <- 绘图数据$fit[1L] + 0.2
    write.csv(绘图数据, 本步文件路径(本步目录, "输出_绘图数据.csv"), row.names = FALSE)
    实际绘图数据 <- read.csv(本步文件路径(本步目录, "输出_绘图数据.csv"))
    核对结果数值(正式拟合, 实际绘图数据$fit, "绘图")

    # 【可修改】仅图的外观；模型和图线均来自同一正式对象，没有手写系数。
    png(本步文件路径(本步目录, "输出_拟合图.png"), width = 1200, height = 900, res = 150)
    tryCatch({
      par(mar = c(4.5, 4.5, 3.5, 1), family = "sans")
      plot(本步数据$x, 本步数据$y, pch = 19, col = "#526B85", cex = 0.85,
           xlab = "Simulated x", ylab = "Simulated y", main = "Synthetic only: one-step technical check")
      lines(实际绘图数据$x, 实际绘图数据$fit, col = "#BD4F2A", lwd = 2)
      legend("topleft", legend = c("Simulated observations", "lm fit from saved model"),
             col = c("#526B85", "#BD4F2A"), pch = c(19, NA), lty = c(NA, 1), bty = "n")
    }, finally = dev.off())
    cat("本步通过：完整输入、模型表和绘图数值一致。此处停止，没有启动下一步。\n")
  }, warning = function(w) cat("警告：", conditionMessage(w), "\n"),
     error = function(e) cat("本步停止：", conditionMessage(e), "\n"))
}
运行本步()
