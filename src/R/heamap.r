data = read.csv(file="/projects/sate7/smirarab/avianjarvis/ST/trees.compatibility.stat",sep =" ",head=T)

m = matrix(data$Comp1,nrow=33)

dimnames(m) <- list(data$Est[1:33], data$Est[1:33])

pdf("heatma.pdf")
heatmap(1-m,symm=T, margins=c(7,7))
dev.off()