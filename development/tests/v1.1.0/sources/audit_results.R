# 独立核查已保存的模拟结果。该脚本没有替研究者选方法或运行真实研究的功能。
参数 <- commandArgs(TRUE); stopifnot(length(参数) == 1L)
运行目录 <- normalizePath(参数[1], winslash = "/", mustWork = TRUE)
审计目录 <- file.path(运行目录, "audit")
if (file.exists(file.path(审计目录, "numeric_checks.csv"))) stop("已有核查证据，拒绝覆盖。")
核查结果 <- list()
核查 <- function(名称, 表达式, 详情 = "") {
  成功 <- isTRUE(表达式)
  核查结果[[length(核查结果) + 1L]] <<- data.frame(check = 名称, pass = 成功, detail = 详情)
  if (!成功) warning(paste("核查失败:", 名称), call. = FALSE)
}
接近 <- function(x, y, tol = 1e-10) {
  if (is.data.frame(x)) x <- as.matrix(x)
  if (is.data.frame(y)) y <- as.matrix(y)
  isTRUE(all.equal(unname(x), unname(y), tolerance = tol, check.attributes = FALSE))
}
读表 <- function(步骤, 名字) read.csv(file.path(运行目录, 步骤, 名字), stringsAsFactors = FALSE, check.names = FALSE)
同群 <- function(x) outer(x, x, "==")
独立ARI <- function(a, b) {
  T <- table(a, b); choose2 <- function(x) x*(x-1)/2
  A <- sum(choose2(T)); B <- sum(choose2(rowSums(T))); C <- sum(choose2(colSums(T)))
  E <- B*C/choose2(length(a)); (A-E)/((B+C)/2-E)
}

# 一、Spearman：独立地转成平均秩再计算 Pearson；独立算渐近 t 和 Holm。
s <- "01_Spearman_中文 空格"
d <- 读表(s, "输入_模拟数据.csv"); t <- 读表(s, "输出_Spearman结果.csv")
model <- readRDS(file.path(运行目录, s, "输出_Spearman对象.rds"))
ref <- do.call(rbind, lapply(seq_len(nrow(t)), function(i) {
  cols <- c(t$variable_1[i], t$variable_2[i]); z <- d[complete.cases(d[cols]), cols]
  rho <- cor(rank(z[[1]], ties.method = "average"), rank(z[[2]], ties.method = "average"), method = "pearson")
  stat <- rho * sqrt((nrow(z)-2)/(1-rho^2))
  data.frame(n = nrow(z), rho = rho, p = 2*pt(-abs(stat), df = nrow(z)-2))
}))
o <- order(ref$p); holm <- numeric(nrow(ref)); holm[o] <- pmin(1, cummax((nrow(ref):1)*ref$p[o]))
核查("Spearman_average_rank_reference", 接近(t$rho, ref$rho))
核查("Spearman_pairwise_valid_n", identical(t$n_valid, ref$n) && length(unique(ref$n)) > 1L,
       paste("valid n:", paste(ref$n, collapse = "/")))
核查("Spearman_ties_and_missing_retained", all(t$tied_x & t$tied_y) && all(t$n_excluded_pair > 0) && nrow(d) == 30L)
核查("Spearman_asymptotic_p_and_Holm", 接近(t$p_raw, ref$p) && 接近(t$p_holm, holm))
核查("Spearman_saved_object_table_plot_equal", 接近(t$rho, model$results$rho) && 接近(读表(s, "输出_绘图数据.csv")$rho, t$rho))

# 二、PCA：直接从已保存输入计算协方差特征值和数值重构。
p <- "02_PCA_模拟"; d <- 读表(p, "输入_模拟数据.csv"); X <- as.matrix(d[-1])
fit <- readRDS(file.path(运行目录, p, "输出_PCA对象.rds"))
L <- as.matrix(读表(p, "输出_载荷.csv")[-1]); S <- as.matrix(读表(p, "输出_得分.csv")[-1])
v <- 读表(p, "输出_解释方差.csv"); reconstructed <- as.matrix(读表(p, "输出_重构数据.csv")[-1])
Z <- scale(X); eigen_ref <- eigen(cov(Z), symmetric = TRUE)$values
核查("PCA_eigenvalue_and_variance_sum", 接近(v$eigenvalue, eigen_ref) && abs(sum(v$proportion)-1) < 1e-12)
核查("PCA_orthonormal_loadings_and_score_covariance", 接近(crossprod(L), diag(ncol(L))) && 接近(diag(cov(S)), v$eigenvalue))
核查("PCA_complete_original_scale_reconstruction", max(abs(reconstructed-X)) < 1e-10 && 接近(S %*% t(L), Z))
signs <- diag(c(-1,1,-1,1))
核查("PCA_sign_invariance", 接近((S %*% signs) %*% t(L %*% signs), S %*% t(L)))
核查("PCA_object_csv_plot_equal", 接近(fit$rotation, L) && 接近(fit$x, S) && 接近(读表(p, "输出_绘图数据.csv")[c("PC1","PC2")], S[,1:2]))
rank_data <- as.matrix(read.csv(file.path(审计目录, "输入_秩亏模拟.csv")))
rank_fit <- prcomp(rank_data, center = TRUE, scale. = TRUE)
核查("PCA_rank_deficiency_zero_variance_detected", sum(rank_fit$sdev^2 < max(rank_fit$sdev^2)*1e-10) == 1L,
       "one redundant variable; do not interpret zero-variance component")
deg_data <- as.matrix(read.csv(file.path(审计目录, "输入_等特征值模拟.csv")))
deg_fit <- prcomp(deg_data, center = TRUE, scale. = TRUE)
theta <- pi/5; Q <- matrix(c(cos(theta), sin(theta), -sin(theta), cos(theta)), 2)
L2 <- deg_fit$rotation %*% Q; S2 <- deg_fit$x %*% Q
核查("PCA_equal_eigenvalue_subspace_invariance", 接近(deg_fit$sdev[1], deg_fit$sdev[2]) &&
       接近(L2%*%t(L2), deg_fit$rotation%*%t(deg_fit$rotation)) && 接近(S2%*%t(L2), scale(deg_data)) &&
       !接近(L2, deg_fit$rotation), "compare projector/reconstruction rather than literal loading columns")

# 三、两种聚类：不依赖类别编号；检验标准化、距离、中心、代价和扰动输出。
cluster_checks <- function(scene, hierarchical = FALSE) {
  d <- 读表(scene, "输入_模拟数据.csv"); z <- scale(as.matrix(d[c("feature_1","feature_2","feature_3")]))
  t <- 读表(scene, "输出_分群.csv"); ob <- readRDS(file.path(运行目录, scene, "输出_聚类对象.rds"))
  centers <- 读表(scene, "输出_标准化中心.csv"); counts <- 读表(scene, "输出_分群人数.csv")
  expected_centers <- t(vapply(sort(unique(t$cluster)), function(g) colMeans(z[t$cluster == g,,drop=FALSE]), numeric(3)))
  tag <- if (hierarchical) "Hierarchical" else "Kmeans"
  核查(paste0(tag, "_scaling_centers_counts"), 接近(centers[-1], expected_centers) &&
         接近(counts$n, as.numeric(table(t$cluster))) && 接近(ob$center, colMeans(as.matrix(d[c("feature_1","feature_2","feature_3")]))))
  ref_label <- if (hierarchical) cutree(hclust(dist(z, method="euclidean"), method="ward.D2"), k=3) else {
    set.seed(20261017L); kmeans(z, 3L, nstart=25L, iter.max=100L, algorithm="Hartigan-Wong")$cluster
  }
  核查(paste0(tag, "_saved_refit_coassignment"), identical(同群(t$cluster), 同群(ref_label)) && identical(t$cluster, unname(ob$labels)))
  perm <- c(3L,1L,2L)[t$cluster]
  核查(paste0(tag, "_label_permutation_and_simulated_recovery"), identical(同群(perm), 同群(t$cluster)) &&
         abs(独立ARI(perm,t$cluster)-1)<1e-12 && abs(独立ARI(t$cluster,d$generating_group)-1)<1e-12,
         "generating group is audit only; not a fit input")
  st <- 读表(scene, "输出_扰动稳定性.csv")
  核查(paste0(tag, "_small_noise_stability"), nrow(st)==20L && all(is.finite(st$adjusted_rand)) &&
         all(st$adjusted_rand >= 0.95 & st$adjusted_rand <= 1+1e-12) && 接近(st$adjusted_rand, ob$stability$adjusted_rand),
         sprintf("min ARI %.4f; deliberately separated simulation; not bootstrap or clinical validation", min(st$adjusted_rand)))
  pp <- 读表(scene, "输出_绘图数据.csv")
  核查(paste0(tag, "_plot_numeric_source"), 接近(pp$z_feature_1,z[,1]) && 接近(pp$z_feature_2,z[,2]) && identical(pp$cluster,t$cluster))
  if (!hierarchical) {
    within_ref <- sum(vapply(seq_len(nrow(z)), function(i) sum((z[i,]-expected_centers[t$cluster[i],])^2), numeric(1)))
    核查("Kmeans_within_cluster_cost", 接近(ob$fit$tot.withinss, within_ref))
  } else 核查("Hierarchical_merge_distance", identical(ob$fit$method,"ward.D2") && 接近(ob$fit$height, hclust(dist(z),method="ward.D2")$height))
}
cluster_checks("03_Kmeans_模拟"); cluster_checks("04_Hierarchical_模拟", TRUE)

# 四、验证审计会拒绝篡改，而不是只检查文件是否存在。保留篡改副本，不动正式结果。
检查相关表 <- function(table, object) {
  if (!接近(table$rho, object$results$rho) || !接近(table$p_holm, object$results$p_holm)) stop("导出表与模型对象不一致")
  TRUE
}
检查绘图表 <- function(plot_table, formal_table) {
  if (!接近(plot_table$rho, formal_table$rho)) stop("绘图数字与正式结果不一致")
  TRUE
}
s <- "01_Spearman_中文 空格"; original <- 读表(s,"输出_Spearman结果.csv")
obj <- readRDS(file.path(运行目录,s,"输出_Spearman对象.rds"))
tampered <- original; tampered$rho[1] <- tampered$rho[1]+0.1
write.csv(tampered,file.path(审计目录,"篡改副本_相关表.csv"),row.names=FALSE)
核查("detect_export_table_object_mismatch", inherits(try(检查相关表(tampered,obj),silent=TRUE),"try-error"))
plot_tampered <- 读表(s,"输出_绘图数据.csv"); plot_tampered$rho[2] <- plot_tampered$rho[2]-0.1
write.csv(plot_tampered,file.path(审计目录,"篡改副本_绘图数据.csv"),row.names=FALSE)
核查("detect_plot_formal_result_mismatch", inherits(try(检查绘图表(plot_tampered,original),silent=TRUE),"try-error"))

结果 <- do.call(rbind, 核查结果)
write.csv(结果, file.path(审计目录,"numeric_checks.csv"), row.names=FALSE, fileEncoding="UTF-8")
capture.output(sessionInfo(), file=file.path(审计目录,"audit_sessionInfo.txt"))
print(结果, row.names=FALSE)
if (!all(结果$pass)) stop("存在数值核查失败。请保留证据后修复。")
cat(nrow(结果), "numeric checks passed.\n")
