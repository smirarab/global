require(ggplot2)

# Read alignment stats
faa = read.csv("distance.faa.removed.stat",sep=" ",header=F)
faa$DS <- "Amino Acid"
fna = read.csv("distance.fna.removed.stat",sep=" ",header=F)
fna$DS <- "Straight DNA"
fna2aa = read.csv("distance.fna2aa.removed.stat",sep=" ",header=F)
fna2aa$DS <- "Codon DNA"
alg = rbind(faa,fna,fna2aa)
# Depict alignment stats
alg$DS <-factor(alg$DS, levels =  c("Codon DNA","Straight DNA", "Amino Acid"))
rename = list("Average P-Distance" = "ALIGNMENT_ANHD", "Maximum P-Distance" = "ALIGNMENT_MNHD", 
"Alilgnment Length"="ALIGNMENT_COLUMNS_COUNT", "Number of Sequences" = "ALIGNMENT_ROWS_COUNT",
"Gap Percentage" = "ALIGNMENT_PERCENT_BLANKS_MARKER", 
"Average Gap Length"="ALIGNMENT_AVERAGE_GAP_LENGTH","Median Gap Length"="ALIGNMENT_MEDIAN_GAP_LENGTH", "STD Gap Length"="ALIGNMENT_STDDEV_GAP_LENGTH",
"Average Number of Gaps Per Sequence"="ALIGNMENT_AVERAGE_GAPS_PER_SEQUENCE", 
"Total Number of Gaps"="ALIGNMENT_GAPS_COUNT",
"Number of Gap Characters"="ALIGNMENT_BLANKS_COUNT"
)
levels(alg$V2) <- rename
pdf("alignment_stats.pdf")
for (l in levels(alg$V2)) {
  alg.l = alg[which(alg$V2 == l),]
  p = qplot(V3,data=alg.l, main=paste("Histogram of ",l ))+facet_wrap(~DS,scales = "free_y")
  print (p)
}
dev.off()



