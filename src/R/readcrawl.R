#!/usr/bin/env Rscript

# Reads the results from crawling stat files.
# Generates figures, tables, and tests 
#
# Author: smirarab
###############################################################################
close.screen(all.screens=TRUE)
rm(list=ls(all=TRUE))
library(ggplot2)

# settings
#theme_set(theme_bw())
sort.by.factor="raxml_cobalt"
sort.by.stat="MB_FN"
stat.time.suffix="_time"
stat.mem.suffix="_Image_size"
filterout.factors = c("raxml_prank","raxml_probcons","raxml_satchmo", "raxml_muscle","fasttree_opal","raxml_opal")
out.filename="fasttree_raxml"
shapes.pattern=c(1:3,1:3)

#sort.by.factor="raxml_cobalt"
#filterout.factors = c("fasttree_opal","fasttree_mafft","fasttree_clustalw", "fasttree_cobalt")
#out.filename="raxml-all"
#shapes.pattern=c(1:8)


# read where you are, find utilities.R, and source it
argv <- commandArgs(trailingOnly = FALSE)
script_dir <- dirname(substring(argv[grep("--file=", argv)], 8))
if (length(script_dir) > 0) source(paste(script_dir, "utilities.R", sep="/"))

# find out the file to read from input argumetns (default: results.csv)
argv <- commandArgs(trailingOnly = TRUE)
file = "results.csv"
if (length(grep("-in",argv)) > 0) { file = argv[grep("-in",argv)+1] }

# read the file
data<-read.csv(file,head=T,sep=" ")

# filter out specified factors
data = data[which(! data$FACTORS %in% filterout.factors),]
#data$FACTORS = drop.levels(data$FACTORS)
data$FACTORS <- data$FACTORS[, drop = TRUE]

# add a column to be used for sorting the datasets. see settings. 
data = merge( data, 
		data[which(data$STAT==sort.by.stat & data$FACTOR == sort.by.factor),c(1,5)],
		"DATASET",suffixes=c("",".sort"))

# adjust running times to be in hours
data[which(grepl(stat.time.suffix,data$STAT)),"VAL"] = 
		data[which(grepl(stat.time.suffix,data$STAT)),"VAL"]/3600 

# adjust memory to be in mega-bytes (assume already in kilo-bytes)
data[which(grepl(stat.mem.suffix,data$STAT)),"VAL"] = 
		data[which(grepl(stat.mem.suffix,data$STAT)),"VAL"] / 1000

# Assign a number to each Dataset (and print it for future reference)
xformatter <- function(x,N=F) { 
	sapply(x,
			function(x) paste("D",which(levels(data$DATASET) == x),sep="-")
			,simplify=T,USE.NAMES=N)
}
print (xformatter(levels(data$DATASET),T))

lineplot <- function( metric) {		
	p <- qplot(reorder(DATASET,VAL.sort), VAL, data = data[which(data$STAT == metric),], group=FACTORS, geom="line", colour=FACTORS, shape=FACTORS) + 
			scale_x_discrete("Datasets",formatter = xformatter) + 
			geom_point(aes(shape=FACTORS))+ 
			scale_shape_manual("Techniques",values=shapes.pattern)+ 
			labs(colour = "Techniques") 
	return(p)
}

pdf(paste(out.filename,"pdf",sep="."))
p = lineplot("SPFN_SPFN") + ylab("Alignment Error (SPFN)")
print(p)
p = lineplot("ALG_Total_time") + ylab("Alignment Time (hours)")
print(p)
#p = lineplot("ALG_Image_size") + ylab("Alignment Memory (MB)")
#print(p)
p = lineplot("MB_FN") + ylab("Missing Branch Rate (FN)") + scale_y_continuous(formatter = "percent") 
print(p)
p = lineplot("ML_Total_time") + ylab("Maximum Likelihood Running Time (hours)")
print(p)
#p = lineplot("ML_Image_size") + ylab("Maximum Likelihood Memory (MB)")
#print(p)

dev.off()