# EpiStepLab 可选的本步工具：只使用 R 自带功能。
# 将本文件与当前步骤的入口和完整输入一起复制，步骤运行时不依赖 skill 目录。
# 这些检查只能核对技术条件，不能替代研究者的确认或科学判断。

本步文件路径 <- function(本步目录, 相对文件) {
  if (!is.character(相对文件) || !length(相对文件) || anyNA(相对文件) ||
      any(!nzchar(相对文件))) stop("文件名必须是非空的本步相对路径。", call. = FALSE)
  拆分 <- strsplit(gsub("\\\\", "/", 相对文件), "/", fixed = TRUE)
  if (any(grepl("^([A-Za-z]:|[/\\\\])", 相对文件)) ||
      any(vapply(拆分, function(x) ".." %in% x, logical(1)))) {
    stop("输入和输出必须位于本步目录内；请先带齐完整输入。", call. = FALSE)
  }
  根目录 <- normalizePath(本步目录, winslash = "/", mustWork = TRUE)
  路径 <- file.path(根目录, 相对文件)
  for (当前路径 in 路径) {
    已有路径 <- 当前路径
    while (!file.exists(已有路径) && !dir.exists(已有路径)) {
      上级 <- dirname(已有路径)
      if (identical(上级, 已有路径)) break
      已有路径 <- 上级
    }
    真实路径 <- normalizePath(已有路径, winslash = "/", mustWork = TRUE)
    if (!identical(tolower(真实路径), tolower(根目录)) &&
        !startsWith(tolower(真实路径), paste0(tolower(根目录), "/"))) {
      stop("路径经解析后离开本步目录，请复制实际文件后再运行。", call. = FALSE)
    }
  }
  路径
}

检查必需字段 <- function(数据, 必需字段) {
  if (!is.data.frame(数据)) stop("输入必须是数据框。", call. = FALSE)
  缺少 <- setdiff(必需字段, names(数据))
  if (length(缺少)) stop(paste("缺少必需字段：", paste(缺少, collapse = "、")), call. = FALSE)
  if (anyDuplicated(names(数据))) stop("数据包含重复字段名，需先核实。", call. = FALSE)
  invisible(TRUE)
}

检查连接键 <- function(数据, 键字段) {
  if (!length(键字段) || anyDuplicated(键字段)) stop("请明确不重复的连接键字段。", call. = FALSE)
  检查必需字段(数据, 键字段)
  键 <- 数据[, 键字段, drop = FALSE]
  缺失 <- vapply(键, function(x) anyNA(x) ||
                   (is.character(x) && any(!nzchar(trimws(x)))), logical(1))
  if (any(缺失)) stop("连接键存在缺失或空白，请核实后再合并。", call. = FALSE)
  # duplicated.data.frame 支持复合键，不拼接字符串，避免分隔符造成假重复。
  if (anyDuplicated(键)) stop("连接键不唯一；请核实重复记录或复合键。", call. = FALSE)
  invisible(TRUE)
}

记录文件指纹 <- function(本步目录, 相对文件) {
  if (anyDuplicated(相对文件)) stop("指纹清单中有重复文件名。", call. = FALSE)
  路径 <- 本步文件路径(本步目录, 相对文件)
  if (any(!file.exists(路径)) || any(dir.exists(路径))) {
    stop("输入或脚本文件不存在；请带齐完整文件后再运行。", call. = FALSE)
  }
  # MD5 仅用于发现意外变更，不是安全哈希，也不能证明来源可信。
  data.frame(文件 = 相对文件, 字节 = unname(file.info(路径)$size),
             MD5 = unname(tools::md5sum(路径)), check.names = FALSE,
             stringsAsFactors = FALSE)
}

核对文件指纹 <- function(本步目录, 预期指纹) {
  检查必需字段(预期指纹, c("文件", "MD5"))
  if (anyNA(预期指纹$MD5) || any(!nzchar(预期指纹$MD5))) {
    stop("预期指纹有缺失，不能据此核对输入。", call. = FALSE)
  }
  当前 <- 记录文件指纹(本步目录, 预期指纹$文件)
  变更 <- 当前$MD5 != 预期指纹$MD5
  if (any(变更)) stop(paste("文件指纹已变化；本步及相关下游结果需要重查：",
                            paste(当前$文件[变更], collapse = "、")), call. = FALSE)
  invisible(TRUE)
}

检查输出文件 <- function(本步目录, 输出文件, 输入文件) {
  路径 <- 本步文件路径(本步目录, 输出文件)
  输入路径 <- 本步文件路径(本步目录, 输入文件)
  if (anyDuplicated(tolower(路径)) || any(tolower(路径) %in% tolower(输入路径))) {
    stop("输出文件重名或与输入重名，请使用新的明确文件名。", call. = FALSE)
  }
  if (any(file.exists(路径))) stop("已有输出不能自动覆盖；请核实版本并另存后再运行。", call. = FALSE)
  invisible(TRUE)
}

保存运行环境 <- function(本步目录, 文件名 = "检查_运行环境.txt") {
  路径 <- 本步文件路径(本步目录, 文件名)
  writeLines(c(paste("运行时间：", format(Sys.time(), "%Y-%m-%d %H:%M:%S %z")),
               paste("本步目录：", normalizePath(本步目录, winslash = "/")),
               capture.output(sessionInfo())), 路径, useBytes = TRUE)
  invisible(路径)
}

核对结果数值 <- function(正式数值, 待核对数值, 标签 = "结果", 容差 = 1e-10) {
  if (!is.numeric(容差) || length(容差) != 1L || !is.finite(容差) || 容差 < 0) {
    stop("数值核对容差必须是一个有限的非负数。", call. = FALSE)
  }
  if (!is.numeric(正式数值) || !is.numeric(待核对数值) ||
      length(正式数值) != length(待核对数值) ||
      !isTRUE(all.equal(unname(正式数值), unname(待核对数值),
                        tolerance = 容差, check.attributes = FALSE))) {
    stop(paste0(标签, "数值与正式结果不一致，请检查提取、排序或手工改动。"), call. = FALSE)
  }
  invisible(TRUE)
}

核对线性模型表 <- function(模型, 结果表, 容差 = 1e-10) {
  if (!inherits(模型, "lm") || inherits(模型, "glm")) {
    stop("此工具仅核对普通 lm 的系数表；其他模型须按实际类型编写核对。", call. = FALSE)
  }
  检查必需字段(结果表, c("term", "estimate", "std_error", "statistic", "p_value"))
  正式 <- summary(模型)$coefficients
  if (!identical(as.character(结果表$term), rownames(正式))) {
    stop("模型系数项或排序与结果表不一致。", call. = FALSE)
  }
  for (列名 in c("estimate", "std_error", "statistic", "p_value")) {
    列号 <- match(列名, c("estimate", "std_error", "statistic", "p_value"))
    核对结果数值(正式[, 列号], 结果表[[列名]], paste0("模型表 ", 列名), 容差)
  }
  invisible(TRUE)
}
