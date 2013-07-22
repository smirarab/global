#!/usr/bin/env Rscript

# Reads the results from crawling stat files.
# Generates figures, tables, and tests 
#
# Author: smirarab
###############################################################################
library(ggplot2)

# settings
theme_set(theme_bw())
#-----------------------
stat.time.suffix="_time"
stat.mem.suffix="_Image_size"


# read where you are, find utilities.R, and source it
argv <- commandArgs(trailingOnly = FALSE)
script_dir <- dirname(substring(argv[grep("--file=", argv)], 8))
if (length(script_dir) > 0) source(paste(script_dir, "utilities.R", sep="/"))

# find out the file to read from input argumetns (default: results.csv)
argv <- commandArgs(trailingOnly = TRUE)
bdir = "."
if (length(grep("-in",argv)) > 0) { bdir = argv[grep("-in",argv)+1] }

if (!exists("eliminate.ds")) eliminate.ds=c()

alldata<-read.csv(file,head=T,sep=" ")
data<-data.frame()
# read the file
print(directories)
for (dir in names(directories)) {
	d = alldata[which( alldata$DIR == dir & 
					   alldata$FACTORS %in% directories[[dir]] &
					   ! alldata$DATASET %in% eliminate.ds),]
	m  = d
	# -- drop levels that are factored out
	d$FACTORS <- d$FACTORS[, drop = TRUE]
	d$FACTORS=paste(d$FACTORS,dirnames[[dir]],sep="")
	#levels(d$FACTORS) <- 
	if (nrow(data) == 0) {
		data = d
	} else {
		data <- rbind(data,d)
	}	
}
data$FACTORS<-factor(data$FACTORS)
## read the datasets statistics file
dataset.data<-read.csv(datasets.stat.file,head=T,sep=" ")

## filter out specified factors
#data = data[which(! data$FACTORS %in% filterout.factors),]

## -- drop levels that are factored out
data$FACTORS <- data$FACTORS[, drop = TRUE]
data$DATASET <- data$DATASET[, drop = TRUE]
# add a column to be used for sorting the datasets. see settings. 
if (sort.from.data) {
	data = merge( data, 
			data[which(data$STAT==sort.by.stat & data$FACTORS == sort.by.factor),c("DATASET", "REPLICA", "VAL")],
			c("DATASET","REPLICA"),suffixes=c("",".sort"))
} else {
	data = merge( data, 
			dataset.data[which(dataset.data$STAT==sort.by.stat & dataset.data$FACTOR == sort.by.factor),c("DATASET", "REPLICA" ,"VAL")],
			c("DATASET","REPLICA"),suffixes=c("",".sort"))
}
# Assign a number to each Dataset (and print it for future reference)
# define xformatter so that this default formattign is overwitten
if (! exists("xformatter")){
	datasetnames <- dataset.data[which(dataset.data$STAT == "ROWS_COUNT"),c("DATASET","VAL")]
	xformatter <- function(x) { 
		sapply(x, function(x)  paste("D",datasetnames[which(levels(datasetnames$DATASET) == x),"VAL"],sep="") )
	}
}
print (xformatter(levels(data$DATASET)))

# print the count of rows in each dataset - to be eye balled
print (table(data[which(data$STAT=="SPFN_SPFN"),c("DATASET","FACTORS")])) 

# adjust running times to be in hours
data[which(grepl(stat.time.suffix,data$STAT)),"VAL"] = 
		data[which(grepl(stat.time.suffix,data$STAT)),"VAL"] / 3600 

# adjust memory to be in mega-bytes (assume already in kilo-bytes)
data[which(grepl(stat.mem.suffix,data$STAT)),"VAL"] = 
		data[which(grepl(stat.mem.suffix,data$STAT)),"VAL"] / 1000

# rename technique labels
if (exists("tech.rename")) {
	levels(data$FACTORS)<-tech.rename
}


a = merge(data[data$STAT=="ML_Total_time",],data[data$STAT=="ALG_Total_time",], c("DATASET","REPLICA","DIR","FACTORS","VAL.sort"),all="T")
a$VAL.x[is.na(a$VAL.x)]<-0
a$VAL.y[is.na(a$VAL.y)]<-0
a$VAL=a$VAL.x+a$VAL.y
a$STAT = "Total_Time" 
d <- rbind(data,a[,c("DATASET","REPLICA","DIR","FACTORS","STAT","VAL","VAL.sort")])	
data= d
#assign(deparse(substitute(data)), d , envir = .GlobalEnv)

data$DATASET = reorder(data$DATASET, data$VAL.sort)

# draw a simple line plot of the data:
# X:datasets, Y:metric, color:FACTORS, shape: based on setting shapes.pattern
lineplot <- function( metric, color.caption = "Techniques") {	
	d = data[which(data$STAT == metric),]
	if (nrow(d) < 1) {
		return (paste("WARNNING: metric not found:",metric))
	}
	stat_sum_df <- function(geom="errorbar", ...) { 
		   stat_summary(
				   fun.ymin = function(x) {mean(x)-sd(x)/sqrt(length(x))}, 
				   fun.ymax = function(x) {mean(x)+sd(x)/sqrt(length(x))}, 
				   geom=geom, width=0.05, size = 0.2, linetype=1, ...) 
		 }
	#print (d$FACTORS)
	p <- qplot(reorder(DATASET,VAL.sort), VAL, data = d, colour=FACTORS, 
					shape=FACTORS,
					geom=c("line","point"),
					group=FACTORS, stat="summary", fun.y = "mean", 
					linetype=FACTORS,
					fill=FACTORS
			) +			
			geom_point(size=3, stat="summary", fun.y="mean")+
			scale_x_discrete("Datasets",formatter = xformatter) + 			
			scale_shape_manual(color.caption,values=shapes.pattern)+									
			#geom_line(stat="summary", fun.y = "mean") +
			scale_linetype_manual(color.caption,values=shapes.lt.pattern)+			
			scale_color_manual(color.caption,values=colors)+
			scale_fill_manual(color.caption,values=colors) +
			stat_sum_df()
	return(p)
}

# draw a simple line plot of the data:
# X:datasets, Y:metric, color:FACTORS, shape: based on setting shapes.pattern
barplot <- function( metric, color.caption = "Techniques") {	
	
	d = data[which(data$STAT == metric),]
	if (nrow(d) < 1) {
		return (paste("WARNNING: metric not found:",metric))
	}
	
	## -- drop levels that are factored out
	d$FACTORS <- d$FACTORS[, drop = TRUE]
	d$DATASET <- d$DATASET[, drop = TRUE]
	
	#print (d$FACTORS)
	
	stat_sum_df <- function(geom="errorbar", ...) { 
		stat_summary(				
				fun.y = function(x) {mean(x)},
				fun.ymin = function(x) {mean(x)-sd(x)/sqrt(length(x))}, 
				fun.ymax = function(x) {mean(x)+sd(x)/sqrt(length(x))}, 
				geom=geom, width=0.5, size = 0.3, linetype=1, ...) 
	}
	dodge <- position_dodge(width=0.9) 
	p <- qplot(reorder(DATASET,VAL.sort), VAL, data = d, 
					fill=FACTORS, group=FACTORS, 
					stat="summary", fun.y = "mean", 
					geom="bar", position=dodge) +
			scale_x_discrete("Datasets",formatter = xformatter) + 			
			stat_sum_df(geom = "errorbar", position=dodge)+
			labs(fill = color.caption)+
			scale_color_manual(values=colors)+
			scale_fill_manual(values=colors)
	
	#if (printdf) {
	#	print(d)
	#}
	return(p)
}

scatter_plot <- function(x, y, color.caption = "Techniques") {	
	d = cast(data[which(data$STAT %in% c(x,y)),], DATASET+DIR+FACTORS~STAT,value="VAL",mean)

	stat_sum_df <- function(geom="errorbar", ...) { 
		stat_summary(				
				fun.y = function(x) {mean(x)},
				fun.ymin = function(x) {mean(x)-sd(x)/sqrt(length(x))}, 
				fun.ymax = function(x) {mean(x)+sd(x)/sqrt(length(x))}, 
				geom=geom, width=0.5, size = 0.3, linetype=1, ...) 
	}
	
	if (nrow(d) < 1) {
		return (paste("WARNNING: metric not found:",c(x,y)))
	}
	p <- qplot(d[,x],d[,y],data=d,group=FACTORS,fill=FACTORS,colour=FACTORS,shape=FACTORS) +	
			geom_point(size=3)+
			facet_grid(DATASET~.)+
			scale_shape_manual(color.caption,values=shapes.pattern)+
			labs(colour = color.caption,fill = color.caption)+
			scale_color_manual(values=colors)+
			scale_fill_manual(values=colors)
	
	return(p)
}