# PCA 模拟步骤：不是自动建立临床指数，也不是自动选择聚类。
# 【已确认·仅模拟】4 个连续变量，居中+标准化，缺失行先拒绝而不默认插补。
# 完整主成分用于重构核查；二维图仅用于展示，不解释成疾病机制。
入口 <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
source(file.path(dirname(入口), "本步工具.R"), encoding = "UTF-8")
步骤 <- 初始化本步(); 数据 <- 步骤$数据; 决策 <- 步骤$决策; 本步 <- 步骤$目录

# 一、读取与检查；本步不自行决定删列或补值。
变量 <- c("measure_1", "measure_2", "measure_3", "measure_4")
if (!all(变量 %in% names(数据))) stop("PCA 缺少所需字段。", call. = FALSE)
if (!identical(决策$标准化, "center_and_scale") || !identical(决策$缺失处理, "reject_and_discuss")) stop("PCA 标准化或缺失方案未确认。", call. = FALSE)
X <- as.matrix(数据[变量])
if (anyNA(X) || any(!is.finite(X))) stop("PCA 存在缺失或非有限值，请先讨论处理，未自动插补。", call. = FALSE)
if (any(apply(X, 2, sd) == 0)) stop("PCA 存在常量列，不能按本方案标准化，请确认变量处理。", call. = FALSE)

# 二、PCA：符号正负可以翻转，完整重构和子空间才是核查依据。
拟合 <- prcomp(X, center = TRUE, scale. = TRUE)
解释 <- data.frame(component = colnames(拟合$rotation), eigenvalue = 拟合$sdev^2,
                   proportion = 拟合$sdev^2 / sum(拟合$sdev^2))
解释$cumulative <- cumsum(解释$proportion)
解释$near_zero <- 解释$eigenvalue < max(解释$eigenvalue) * 1e-10
载荷 <- data.frame(variable = rownames(拟合$rotation), 拟合$rotation, check.names = FALSE)
得分 <- data.frame(id = 数据$id, 拟合$x, check.names = FALSE)
重构标准 <- 拟合$x %*% t(拟合$rotation)
重构原始 <- sweep(sweep(重构标准, 2, 拟合$scale, "*"), 2, 拟合$center, "+")
最大重构误差 <- max(abs(重构原始 - X))
符号 <- rep(c(-1, 1), length.out = ncol(拟合$x))
翻转重构 <- sweep(拟合$x, 2, 符号, "*") %*% t(sweep(拟合$rotation, 2, 符号, "*"))
符号重构误差 <- max(abs(翻转重构 - 重构标准))
if (最大重构误差 > 1e-10 || 符号重构误差 > 1e-12) stop("PCA 重构或符号不变性核对失败。", call. = FALSE)

# 三、保存实际对象、用于后续计算的全部得分及实际展示数据。
写结果表(解释, "解释方差", 本步); 写结果表(载荷, "载荷", 本步); 写结果表(得分, "得分", 本步)
写结果表(data.frame(id = 数据$id, 重构原始, check.names = FALSE), "重构数据", 本步)
写结果表(得分[c("id", "PC1", "PC2")], "绘图数据", 本步)
saveRDS(拟合, file.path(本步, "输出_PCA对象.rds"))
png(file.path(本步, "输出_PCA图.png"), width = 1250, height = 650, res = 130)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 4, 1))
barplot(解释$proportion, names.arg = 解释$component, col = "#3F7D92", ylim = c(0, 1),
        ylab = "Proportion of variance", main = "SIMULATED ONLY: PCA variance")
plot(拟合$x[, 1], 拟合$x[, 2], pch = 16, col = "#3F7D9299", xlab = sprintf("PC1 (%.1f%%)", 100 * 解释$proportion[1]),
     ylab = sprintf("PC2 (%.1f%%)", 100 * 解释$proportion[2]), main = "Standardized features; exploratory scores")
abline(h = 0, v = 0, col = "grey80", lty = 2)
dev.off()

# 四、核对：不把临近零特征值当成有意义的新维度。
读回 <- read.csv(file.path(本步, "输出_解释方差.csv"))
stopifnot(isTRUE(all.equal(读回$proportion, 解释$proportion, tolerance = 1e-12)))
完成记录(本步, data.frame(check = c("input_rows", "center_scale", "near_zero_components", "max_reconstruction_error", "sign_invariance_error"),
             value = c(nrow(X), "TRUE/TRUE", sum(解释$near_zero), format(最大重构误差, digits = 16), format(符号重构误差, digits = 16))))
