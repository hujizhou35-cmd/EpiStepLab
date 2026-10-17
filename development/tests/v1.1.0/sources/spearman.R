# Spearman 模拟步骤。这里的确认只来自测试场景，不可用于真实研究。
# 【已确认·仅模拟】3 个预先指定变量、逐对完整观测、保留并列秩；
# 独立观测模拟样本；exact=FALSE，采用渐近 P 值；3 对检验用 Holm 校正。
# 【可修改】图宽高、颜色与标题。真实研究变更分析参数需要另行讨论。
入口 <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
source(file.path(dirname(入口), "本步工具.R"), encoding = "UTF-8")
步骤 <- 初始化本步(); 数据 <- 步骤$数据; 决策 <- 步骤$决策; 本步 <- 步骤$目录

# 一、读取与检查：不允许把普通独立样本推断直接用在复杂调查数据上。
if (!identical(决策$抽样结构, "independent_simulated")) stop("普通 Spearman P 值不适用于本场景的复杂调查结构，请讨论设计一致的方法。", call. = FALSE)
if (!identical(决策$缺失处理, "pairwise_complete") || !identical(决策$多重比较, "holm")) stop("缺失处理或多重比较方案未确认。", call. = FALSE)
变量 <- c("marker_a", "marker_b", "marker_c")
if (!all(变量 %in% names(数据))) stop("Spearman 缺少所需字段。", call. = FALSE)
if (any(vapply(数据[变量], function(x) any(!is.finite(x) & !is.na(x)), logical(1)))) stop("存在非有限值，请讨论处理。", call. = FALSE)

# 二、逐对相关：有效样本数可以不同，不自动补值或删除整行。
变量对 <- combn(变量, 2, simplify = FALSE)
结果 <- do.call(rbind, lapply(变量对, function(对) {
  有效 <- complete.cases(数据[对]); x <- 数据[[对[1]]][有效]; y <- 数据[[对[2]]][有效]
  if (length(x) < 4 || length(unique(x)) < 2 || length(unique(y)) < 2) stop("可用样本或变异不足，不能估计本对相关。", call. = FALSE)
  模型 <- cor.test(x, y, method = "spearman", exact = FALSE, continuity = FALSE)
  data.frame(variable_1 = 对[1], variable_2 = 对[2], n_total = nrow(数据), n_valid = length(x),
             n_excluded_pair = sum(!有效), tied_x = anyDuplicated(x) > 0L, tied_y = anyDuplicated(y) > 0L,
             rho = unname(模型$estimate), p_raw = 模型$p.value, stringsAsFactors = FALSE)
}))
结果$p_holm <- p.adjust(结果$p_raw, method = "holm")
结果$inference <- "iid simulation; asymptotic; exact=FALSE; Holm across 3 prespecified pairs"

# 三、保存：图与表共同使用同一正式结果，不手写 rho 或 P 值。
写结果表(结果, "Spearman结果", 本步)
saveRDS(list(results = 结果, variables = 变量, missing_policy = 决策$缺失处理,
             multiplicity = 决策$多重比较), file.path(本步, "输出_Spearman对象.rds"))
写结果表(结果[c("variable_1", "variable_2", "n_valid", "rho", "p_holm")], "绘图数据", 本步)
png(file.path(本步, "输出_Spearman相关.png"), width = 1200, height = 850, res = 130)
par(mar = c(5, 5, 5, 2))
位置 <- barplot(结果$rho, ylim = c(-1.12, 1.12), names.arg = paste(结果$variable_1, 结果$variable_2, sep = " / "),
                 las = 1, cex.names = 0.85, col = "#3F7D92", ylab = "Spearman rho", main = "SIMULATED ONLY: pairwise Spearman correlation")
abline(h = 0, col = "grey35")
text(位置, ifelse(结果$rho >= 0, 结果$rho + 0.06, 结果$rho - 0.06),
     labels = sprintf("rho=%.3f; n=%d", 结果$rho, 结果$n_valid), cex = 0.85)
mtext("Ties retained; pairwise missingness; asymptotic P; Holm across 3 pairs", side = 3, line = 0.4, cex = 0.8)
dev.off()

# 四、核对：从保存后的 CSV 读回；数值必须与实际对象一致。
读回 <- read.csv(file.path(本步, "输出_Spearman结果.csv"))
stopifnot(isTRUE(all.equal(读回$rho, 结果$rho, tolerance = 1e-12)),
          isTRUE(all.equal(读回$p_holm, 结果$p_holm, tolerance = 1e-12)))
完成记录(本步, data.frame(check = c("input_rows", "pairwise_n", "missingness_not_imputed", "csv_object_equal"),
             value = c(nrow(数据), paste(结果$n_valid, collapse = "/"), "TRUE", "TRUE")))
