# 聚类模拟步骤。K-means 与层次聚类分别在独立目录、独立会话运行。
# 【已确认·仅模拟】同一模拟连续变量、标准化、欧氏距离、k=3。
# k=3 的依据仅是本模拟数据预先设定的 3 组，不可迁移为真实研究的默认值。
# 稳定性这里只演示固定缩放下小扰动敏感性；不是临床分型验证。
入口 <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
source(file.path(dirname(入口), "本步工具.R"), encoding = "UTF-8")
步骤 <- 初始化本步(); 数据 <- 步骤$数据; 决策 <- 步骤$决策; 本步 <- 步骤$目录

# 一、读取与检查。
变量 <- c("feature_1", "feature_2", "feature_3")
if (!all(变量 %in% names(数据))) stop("聚类缺少所需字段。", call. = FALSE)
if (!identical(决策$标准化, "center_and_scale") || !identical(决策$距离, "euclidean")) stop("聚类距离或标准化方案未确认。", call. = FALSE)
if (!identical(决策$分群数, "3") || !identical(决策$分群依据, "prespecified_simulated_generating_groups")) stop("聚类 k 或选择依据未确认，不能自动选择。", call. = FALSE)
X <- as.matrix(数据[变量])
if (anyNA(X) || any(!is.finite(X)) || any(apply(X, 2, sd) == 0)) stop("聚类输入存在缺失、非有限值或常量列，请讨论处理。", call. = FALSE)
Z <- scale(X); k <- 3L

# 二、分别拟合；固定种子和多起点只用于可复核，不保证全局最优。
拟合一次 <- function(Z, 方法, 种子) {
  set.seed(种子)
  if (identical(方法, "kmeans")) {
    fit <- kmeans(Z, centers = k, nstart = 25L, iter.max = 100L, algorithm = "Hartigan-Wong")
    if (fit$ifault != 0L) stop("K-means 未正常收敛。", call. = FALSE)
    return(list(labels = fit$cluster, fit = fit))
  }
  if (identical(方法, "hierarchical_ward_d2")) {
    fit <- hclust(dist(Z, method = "euclidean"), method = "ward.D2")
    return(list(labels = cutree(fit, k = k), fit = fit))
  }
  stop("模拟方法不明。", call. = FALSE)
}
正式 <- 拟合一次(Z, 决策$方法, 20261017L)
标签 <- 正式$labels
结果 <- data.frame(id = 数据$id, cluster = 标签)
规模 <- as.data.frame(table(cluster = 标签)); names(规模)[2] <- "n"
中心 <- do.call(rbind, lapply(sort(unique(标签)), function(g) {
  data.frame(cluster = g, t(colMeans(Z[标签 == g, , drop = FALSE])), check.names = FALSE)
}))

# 三、小扰动稳定性：对相同记录的标准化变量加 N(0,0.03^2) 噪声，20 次。
# 不看标签编号是否相同；比较共同分群矩阵和调整兰德指数（ARI）。
set.seed(831L)
扰动矩阵 <- lapply(seq_len(20L), function(b) matrix(rnorm(length(Z), sd = 0.03), nrow = nrow(Z)))
稳定性 <- do.call(rbind, lapply(seq_along(扰动矩阵), function(b) {
  扰动拟合 <- 拟合一次(Z + 扰动矩阵[[b]], 决策$方法, 2000L + b)
  mask <- upper.tri(同群矩阵(标签))
  data.frame(replicate = b, perturbation_sd = 0.03,
             coassignment_agreement = mean(同群矩阵(标签)[mask] == 同群矩阵(扰动拟合$labels)[mask]),
             adjusted_rand = 调整兰德指数(标签, 扰动拟合$labels))
}))
置换 <- c(3L, 1L, 2L)[标签]
stopifnot(identical(同群矩阵(标签), 同群矩阵(置换)), abs(调整兰德指数(标签, 置换) - 1) < 1e-12)

# 四、保存模型、实际表图数据。输入里的生成组仅用于后续独立技术核查，未参与拟合。
写结果表(结果, "分群", 本步); 写结果表(规模, "分群人数", 本步); 写结果表(中心, "标准化中心", 本步)
写结果表(稳定性, "扰动稳定性", 本步)
绘图 <- data.frame(id = 数据$id, z_feature_1 = Z[, 1], z_feature_2 = Z[, 2], cluster = 标签)
写结果表(绘图, "绘图数据", 本步)
saveRDS(list(fit = 正式$fit, labels = 标签, center = attr(Z, "scaled:center"), scale = attr(Z, "scaled:scale"),
             features = 变量, method = 决策$方法, stability = 稳定性), file.path(本步, "输出_聚类对象.rds"))
png(file.path(本步, "输出_聚类图.png"), width = 1250, height = 650, res = 130)
par(mfrow = c(1, 2), mar = c(4.5, 4.5, 4.5, 1))
颜色 <- c("#3F7D92", "#B56A4B", "#657C4A")
plot(绘图$z_feature_1, 绘图$z_feature_2, col = 颜色[标签], pch = 16,
     xlab = "Standardized feature 1", ylab = "Standardized feature 2",
     main = paste("SIMULATED ONLY:", 决策$方法))
legend("topleft", legend = paste("Cluster", 规模$cluster, "n =", 规模$n), col = 颜色, pch = 16, cex = 0.8, bty = "n")
if (identical(决策$方法, "hierarchical_ward_d2")) {
  plot(正式$fit, labels = FALSE, hang = -1, main = "Ward.D2; Euclidean; prespecified k = 3", xlab = "Simulated records", sub = "")
  rect.hclust(正式$fit, k = 3, border = 颜色)
} else {
  plot(稳定性$replicate, 稳定性$adjusted_rand, type = "b", pch = 16, ylim = c(0, 1.05),
       xlab = "Perturbation replicate", ylab = "Adjusted Rand index", main = "Small-noise sensitivity only")
  abline(h = 1, col = "grey70", lty = 2)
}
dev.off()
完成记录(本步, data.frame(check = c("input_rows", "k_rationale", "label_permutation_ARI", "stability_type", "stability_min_ARI"),
             value = c(nrow(X), 决策$分群依据, "1", "20 small-noise perturbations; not clinical validation", min(稳定性$adjusted_rand))))
