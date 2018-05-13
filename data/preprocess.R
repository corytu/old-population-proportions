# Read older adults proportion data
raw_data <- read.csv("OldRate.csv", fileEncoding = "UTF-8")

# Data preprocessing
timepoints <- c("Y104M12",
                sprintf("Y%dM%02d",
                        rep(105:200, each = 2, length.out = ncol(raw_data)-2),
                        rep(c(6,12), each = 1, length.out = ncol(raw_data)-2)))
names(raw_data) <- c("CountyTown", timepoints)
status <-
  lapply(raw_data[-1],
         function(column) {
           output <- rep(NA, length(column))
           for (i in seq_along(column)) {
             if (column[i] < 7) {output[i] <- "未達高齡化"}
             else if (column[i] < 14) {output[i] <- "高齡化"}
             else if (column[i] < 20) {output[i] <- "高齡"}
             else {output[i] <- "超高齡"}
           }
           return(output)
         })
names(status) <- paste(names(status), "status", sep = "_")
clean_data <- cbind(raw_data, as.data.frame(status))

write.csv(clean_data, "OldRateStatus.csv", row.names = FALSE, fileEncoding = "UTF-8")