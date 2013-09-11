require(ggplot2)


oc <- read.csv('taxon.occupancy.2.csv',header=T,sep=' ')
if (length(names(oc)) == 4) {
	oc <- cast(oc,GENE_ID+Taxon~.,fun.aggregate=sum,value="Len")
	names(oc) <- c("ID","Taxon", "Len")
}
oc$ID<-paste(oc$ID,"",sep="")

ocs <- ddply(oc, .(ID), transform, rescale= scale(Len,center=F))
ocs$Taxon <- with(ocs, reorder(Taxon, Len, FUN = function(x) {return(length(which(x>0)))}))
ocs$ID <- with(ocs, reorder(ID, Len,FUN = length))

png("taxon.occupancy.heatmap.png", 
		width=6*length(levels(ocs$ID))+220,
		height=10*length(levels(ocs$Taxon))+200,res=125)

ggplot(ocs, aes(ID,Taxon)) + geom_tile(aes(fill = rescale),colour = "white") + 
		scale_fill_gradient(low = "white",high = "steelblue")+
		scale_x_discrete(expand = c(0, 0)) +
		scale_y_discrete(expand = c(0, 0)) +
		opts(legend.position = "none",axis.ticks = theme_blank(),
				axis.text.x = theme_text(size=4,angle = 90, hjust = 0, colour = "grey50"))

dev.off()

png("taxon.occupancy.heatmap.2.png", 
		width=1760,
		height=1280,res=125)

ggplot(ocs, aes(ID,Taxon)) + geom_tile(aes(fill = rescale),colour = "white") + 
		scale_fill_gradient(low = "white",high = "steelblue")+
		scale_x_discrete(expand = c(0, 0)) +
		scale_y_discrete(expand = c(0, 0) )+
		opts(legend.position = "none",axis.ticks = theme_blank(),
				axis.text.x = theme_text(size=4,angle = 90, hjust = 0, colour = "grey50"))

dev.off()

