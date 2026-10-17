# 独立技术测试夹具生成器：仅写入一次全新运行目录，不用于研究分析。
参数 <- commandArgs(TRUE)
if (length(参数) != 2L) stop("需要 sources 路径和全新运行路径。")
源目录 <- normalizePath(参数[1], winslash = "/", mustWork = TRUE)
运行目录 <- 参数[2]
if (dir.exists(运行目录)) stop("运行目录已存在，保留既有证据；请选择全新名称。")
dir.create(运行目录, recursive = TRUE)
set.seed(110261017L)

# 一、仅在内存中新建模拟数据；不用任何历史研究个体数据。
相关数据 <- data.frame(id = sprintf("SIM_S_%02d", seq_len(30)),
                         marker_a = rep(1:6, each = 5),
                         marker_b = c(2,1,2,3,2, 2,3,4,3,3, 4,2,4,4,5, 5,4,6,5,5, 6,5,6,7,6, 7,6,7,8,7),
                         marker_c = c(8,4,7,3,6, 5,8,2,7,3, 6,2,8,3,7, 2,6,1,8,4, 7,5,1,6,2, 4,1,5,2,3))
相关数据$marker_a[c(2, 17)] <- NA
相关数据$marker_b[c(9, 23, 28)] <- NA
相关数据$marker_c[c(4, 17, 23)] <- NA
隐变量1 <- rnorm(48); 隐变量2 <- rnorm(48)
降维数据 <- data.frame(id = sprintf("SIM_P_%02d", seq_len(48)),
                       measure_1 = 10 + 2 * 隐变量1 + rnorm(48, sd = 0.2),
                       measure_2 = 100 + 20 * 隐变量1 + rnorm(48, sd = 3),
                       measure_3 = -5 + 0.4 * 隐变量2 + rnorm(48, sd = 0.1),
                       measure_4 = 30 + 5 * 隐变量1 - 8 * 隐变量2 + rnorm(48))
生成组 <- rep(1:3, each = 20)
组中心 <- rbind(c(-4,-3,-4), c(0,4,3), c(4,-2,0))
基础 <- 组中心[生成组, ] + matrix(rnorm(180, sd = 0.24), 60, 3)
聚类数据 <- data.frame(id = sprintf("SIM_C_%02d", seq_len(60)),
                       feature_1 = 基础[,1], feature_2 = 基础[,2] * 20,
                       feature_3 = 基础[,3] / 5, generating_group = 生成组)

相关决策 <- c(数据性质 = "SIMULATED_ONLY", 本步确认 = "SIMULATION_ONLY_CONFIRMED", 抽样结构 = "independent_simulated",
               缺失处理 = "pairwise_complete", 多重比较 = "holm")
降维决策 <- c(数据性质 = "SIMULATED_ONLY", 本步确认 = "SIMULATION_ONLY_CONFIRMED", 标准化 = "center_and_scale", 缺失处理 = "reject_and_discuss")
聚类决策 <- c(数据性质 = "SIMULATED_ONLY", 本步确认 = "SIMULATION_ONLY_CONFIRMED", 标准化 = "center_and_scale", 距离 = "euclidean",
               分群数 = "3", 分群依据 = "prespecified_simulated_generating_groups", 方法 = "kmeans")

建步骤 <- function(编号名, 数据, 决策, 源脚本, 应成功 = TRUE, 错误词 = "", 变更后不更新指纹 = FALSE) {
  步骤目录 <- file.path(运行目录, 编号名); dir.create(步骤目录)
  write.csv(数据, file.path(步骤目录, "输入_模拟数据.csv"), row.names = FALSE, na = "", fileEncoding = "UTF-8")
  write.csv(data.frame(参数 = names(决策), 值 = unname(决策)), file.path(步骤目录, "输入_模拟决策.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  stopifnot(file.copy(file.path(源目录, "common.R"), file.path(步骤目录, "本步工具.R")))
  stopifnot(file.copy(file.path(源目录, 源脚本), file.path(步骤目录, "本步分析.R")))
  输入名 <- c("输入_模拟数据.csv", "输入_模拟决策.csv")
  write.csv(data.frame(文件 = 输入名, MD5 = unname(tools::md5sum(file.path(步骤目录, 输入名)))),
            file.path(步骤目录, "输入_文件指纹.csv"), row.names = FALSE, fileEncoding = "UTF-8")
  writeLines(c(paste0("# ", 编号名), "", "全部输入均为此测试生成的模拟数据，与任何真实个人无关。",
               "本步方法和参数是测试场景的约定，不能作为真实研究授权或通用推荐。",
               "在新 R 会话运行：Rscript --vanilla 本步分析.R。运行需要当前步骤内全部输入和本步工具.R。",
               "Windows R 临时目录需要无空格路径；测试入口会限定在项目内，并恢复环境。",
               "目的：检验代码、数值和文件交接。统计科学适用性、复杂抽样、真实分型及研究有效性未由此验证。",
               if (应成功) "预期：当前步骤生成表格、PNG、RDS和核查记录后停止。" else paste0("预期：拒绝继续，原因包含：", 错误词)),
             file.path(步骤目录, "本步说明.md"), useBytes = TRUE)
  if (变更后不更新指纹) {
    数据[1, 2] <- 数据[1, 2] + 100
    write.csv(数据, file.path(步骤目录, "输入_模拟数据.csv"), row.names = FALSE, na = "", fileEncoding = "UTF-8")
  }
  data.frame(case = 编号名, expected_success = 应成功, expected_message = 错误词)
}
清单 <- list(
  建步骤("01_Spearman_中文 空格", 相关数据, 相关决策, "spearman.R"),
  建步骤("02_PCA_模拟", 降维数据, 降维决策, "pca.R"),
  建步骤("03_Kmeans_模拟", 聚类数据, 聚类决策, "clustering.R"),
  建步骤("04_Hierarchical_模拟", 聚类数据, replace(聚类决策, "方法", "hierarchical_ward_d2"), "clustering.R"))
坏常量 <- 降维数据; 坏常量$measure_4 <- 7
坏缺失 <- 降维数据; 坏缺失$measure_2[3] <- NA
缺字段 <- 相关数据; 缺字段$marker_c <- NULL
清单 <- c(清单, list(
  建步骤("05_PCA_常量列拒绝", 坏常量, 降维决策, "pca.R", FALSE, "常量列"),
  建步骤("06_Spearman_调查推断拒绝", 相关数据, replace(相关决策, "抽样结构", "complex_survey"), "spearman.R", FALSE, "复杂调查结构"),
  建步骤("07_Kmeans_未确认k拒绝", 聚类数据, replace(聚类决策, "分群数", "UNCONFIRMED"), "clustering.R", FALSE, "k 或选择依据未确认"),
  建步骤("08_PCA_缺失拒绝", 坏缺失, 降维决策, "pca.R", FALSE, "存在缺失或非有限值"),
  建步骤("09_Spearman_输入修改拒绝", 相关数据, 相关决策, "spearman.R", FALSE, "输入已被修改", TRUE),
  建步骤("10_Spearman_缺字段拒绝", 缺字段, 相关决策, "spearman.R", FALSE, "缺少所需字段"),
  建步骤("11_PCA_未确认方法拒绝", 降维数据, replace(降维决策, "本步确认", "UNCONFIRMED"), "pca.R", FALSE, "研究参数未确认")))
write.csv(do.call(rbind, 清单), file.path(运行目录, "cases.csv"), row.names = FALSE, fileEncoding = "UTF-8")
dir.create(file.path(运行目录, "audit"))
write.csv(data.frame(x = 1:8, y = c(-1,1,-2,2,-3,3,-4,4), z = 1:8 + c(-1,1,-2,2,-3,3,-4,4)),
          file.path(运行目录, "audit", "输入_秩亏模拟.csv"), row.names = FALSE)
write.csv(data.frame(x = c(1,0,-1,0), y = c(0,1,0,-1)), file.path(运行目录, "audit", "输入_等特征值模拟.csv"), row.names = FALSE)
cat("Created simulated fixtures only:", normalizePath(运行目录, winslash = "/"), "\n")
