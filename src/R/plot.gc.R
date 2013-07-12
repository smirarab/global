require(ggplot2)


f = read.csv("gc.stat",sep=" ")
fall=f[,c(1,2,3,4,9,10,11,12)]
fall$GC<-fall[,6]+fall[,7]
fdall = melt(fall,id=c("DATASET","GENE","SEQUENCE","TAXON"))
levels(fdall$variable)<-c("A","C","G","T","GC")

pdf("allgenes_nucfreq.pdf")
qplot(variable,value,data=fdall,geom="boxplot", color=variable)+facet_grid(DATASET~., scales = "free")
dev.off()

pdf("pT_ACGT_point.pdf",width=12,height=8)
qplot(reorder(TAXON,value),value,data=fdall,geom="point",stat="summary", fun.y = "mean", color=variable,xlab="taxon")+ opts(axis.text.x = theme_text(angle = 90))+facet_grid(DATASET~., scales = "free")
dev.off()


fcg=melt(fall[,c(1,2,3,4,9)],id=c("DATASET","GENE","SEQUENCE","TAXON"))
fcg<-f[,c(1,2,3,4)]
fcg$ALL<-f[,10]+f[,11]
fcg$C1<-f[,18]+f[,19]
fcg$C2<-f[,26]+f[,27]
fcg$C3<-f[,34]+f[,35]
fcg=melt(fcg,id=c("DATASET","GENE","SEQUENCE","TAXON"))


#pdf("pGpP_CG_box.pdf",width=16,height=8)
#qplot(variable,value,data=fcg,geom="boxplot",color=variable,ylab="CG Content",outlier.size=0.2)+
#		facet_wrap(~GENE, ncol=25)+ 
#		opts(axis.ticks = theme_blank(), axis.text.x = theme_blank(),axis.title.x = theme_blank(),
#				strip.text.x = theme_text(angle=90))
#dev.off()

pdf("perposition_GC_content.pdf",width=16,height=8)
qplot(variable,value,data=fcg,geom="boxplot", color=variable,ylab="GC Content")		
dev.off()

pdf("pTpP_GC_point.pdf",width=12,height=8)
qplot(reorder(TAXON,value),value,data=fcg,geom="point",stat="summary", fun.y = "mean", color=variable,xlab="taxon")+ opts(axis.text.x = theme_text(angle = 90))+facet_grid(DATASET~., scales = "free")
dev.off()

pdf("pTpP_GC_box.pdf",width=14,height=12)
qplot(reorder(TAXON,value),value,data=fcg,geom="boxplot",xlab="taxon",ylab="GC content",outlier.size=0.4)+ opts(axis.text.x = theme_text(angle = 90))+facet_grid(variable~., scales = "free")
dev.off()

quit()


