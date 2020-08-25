# Common Utility functions
# 
# Author: smirarab
###############################################################################

std.error <- function(x,na.rm=T) {sqrt(var(x,na.rm=na.rm)/length(x))}

stat_sum_df <- function(geom="errorbar", width=0.05, size = 0.2, linetype=1, ...) {
stat_summary( fun.ymin = function(x) {mean(x)-sd(x)/sqrt(length(x))},
		fun.ymax = function(x) {mean(x)+sd(x)/sqrt(length(x))}, 
                geom=geom, width=width, size=size, linetype=linetype, ...)
}
