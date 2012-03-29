data = read.csv(file="/projects/sate7/smirarab/avianjarvis/thirdround/supermatrix/tree.diff.csv",sep =" ",head=T)

m = matrix(data$MissingRate,nrow=6)

dimnames(m) <- list(data$Est[1:6], data$Est[1:6])

pdf("heatma.pdf")
heatmap(1-m,symm=T, margins=c(7,7))
dev.off()