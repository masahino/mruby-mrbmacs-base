# Line comment, keywords, operators, infix operators, strings, and numbers.
values <- c(1L, 2.5, 3e2, NA_real_, Inf, NaN)
names(values) <- c("one", "two", "three", "na", "inf", "nan")

`%between%` <- function(value, bounds) {
  value >= bounds[[1]] && value <= bounds[[2]]
}

summarize <- function(items, remove_na = TRUE) {
  if (length(items) == 0) {
    return(NULL)
  }

  list(
    mean = mean(items, na.rm = remove_na),
    selected = items[items %between% c(1, 100)]
  )
}

result <- summarize(values)
message(sprintf('mean=%s', result$mean))
