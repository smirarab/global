# Common Utility functions
# 
# Author: smirarab
###############################################################################

std.error <- function(x,na.rm=T) sqrt(var(x,na.rm=na.rm)/length(x))
