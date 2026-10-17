# 仅供 EpiStepLab v1.1.0 的模拟方法技术测试；不能作为真实研究授权。
# 此文件随每一步复制，新的 R 会话仅依赖本步内的文件。
本步目录 <- function() {
  路径参数 <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(路径参数) != 1L) stop("请用 Rscript --vanilla 本步分析.R 运行本模拟步骤。", call. = FALSE)
  normalizePath(dirname(sub("^--file=", "", 路径参数)), winslash = "/", mustWork = TRUE)
}

初始化本步 <- function() {
  本步 <- 本步目录()
  if (length(list.files(本步, pattern = "^输出_"))) stop("本步已有输出，请另建运行副本，避免覆盖证据。", call. = FALSE)
  清单 <- read.csv(file.path(本步, "输入_文件指纹.csv"), stringsAsFactors = FALSE, check.names = FALSE)
  输入路径 <- file.path(本步, 清单$文件)
  if (any(!file.exists(输入路径))) stop("缺少本步完整输入。", call. = FALSE)
  if (any(unname(tools::md5sum(输入路径)) != 清单$MD5)) stop("输入已被修改；请核实版本，不继续分析。", call. = FALSE)
  决策表 <- read.csv(file.path(本步, "输入_模拟决策.csv"), stringsAsFactors = FALSE, check.names = FALSE)
  决策 <- as.list(setNames(决策表$值, 决策表$参数))
  if (!identical(决策$数据性质, "SIMULATED_ONLY")) stop("仅允许明确标记的模拟数据。", call. = FALSE)
  if (!identical(决策$本步确认, "SIMULATION_ONLY_CONFIRMED")) stop("本步研究参数未确认。", call. = FALSE)
  数据 <- read.csv(file.path(本步, "输入_模拟数据.csv"), stringsAsFactors = FALSE, check.names = FALSE)
  if (anyDuplicated(数据$id) || anyNA(数据$id)) stop("模拟记录键缺失或重复。", call. = FALSE)
  list(目录 = 本步, 数据 = 数据, 决策 = 决策)
}

写结果表 <- function(表, 名字, 本步) {
  路径 <- file.path(本步, paste0("输出_", 名字, ".csv"))
  if (file.exists(路径)) stop("已有结果文件，停止覆盖。", call. = FALSE)
  write.csv(表, 路径, row.names = FALSE, na = "", fileEncoding = "UTF-8")
}

完成记录 <- function(本步, 检查) {
  写结果表(检查, "检查记录", 本步)
  capture.output(sessionInfo(), file = file.path(本步, "输出_运行环境.txt"))
  writeLines(c("仅为模拟技术验证；不是研究方法推荐或真实研究结论。",
               "本步执行完成并停止。未生成后续研究步骤。"), file.path(本步, "输出_完成说明.txt"), useBytes = TRUE)
}

同群矩阵 <- function(标签) outer(标签, 标签, "==")

调整兰德指数 <- function(标签1, 标签2) {
  # 只用列联表计数，因此允许不同的类别编号。
  表 <- table(标签1, 标签2)
  组合2 <- function(x) x * (x - 1) / 2
  n2 <- 组合2(sum(表))
  a <- sum(组合2(表)); b <- sum(组合2(rowSums(表))); c <- sum(组合2(colSums(表)))
  期望 <- b * c / n2
  分母 <- (b + c) / 2 - 期望
  if (分母 == 0) return(if (identical(同群矩阵(标签1), 同群矩阵(标签2))) 1 else NA_real_)
  (a - 期望) / 分母
}
