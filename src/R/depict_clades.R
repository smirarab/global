require(ggplot2)
require(reshape)

#rm(list=ls())

if (ST) {
clade.colors <- c("Strong Support"=rgb(1, 133, 113, max = 255), "Weak Support"=rgb(128, 205, 193, max = 255), 
		"Compatible (Weak Rejection)"=rgb(223, 194, 125, max = 255), "Strong Rejection"=rgb(166, 97, 26, max = 255), "Missing"=rgb(192, 192, 192, max = 255) )
rename.c <- list(
		"Strong Support"="IS_MONO-IS_MONO","Weak Support"="IS_MONO-CAN_MONO",
		"Compatible (Weak Rejection)"="CAN_MONO-CAN_MONO", 
		"Compatible (Weak Rejection)"="NOT_MONO-CAN_MONO", 
		"Strong Rejection"="NOT_MONO-NOT_MONO",
                "Missing"="IS_MONO_INCOMPLETE-CAN_MONO","Missing"= "IS_MONO_INCOMPLETE-IS_MONO_INCOMPLETE","Missing"="NOT_MONO-CAN_MONO_INCOMPLETE", "Missing"="NO_CLADE-NO_CLADE","Missing"="CAN_MONO_INCOMPLETE-CAN_MONO_INCOMPLETE", "Missing"="IS_MONO_INCOMPLETE-CAN_MONO_INCOMPLETE"
)

} else {
clade.colors <- c("Strong Support"=rgb(1, 133, 113, max = 255), "Strong Support (partially missing)"=rgb(178, 223, 138, max = 255),
		"Weak Support"=rgb(128, 205, 193, max = 255), "Weak Support (partially missing)"=rgb(166, 206, 227, max = 255),
		"Compatible (Weak Rejection)"=rgb(223, 194, 125, max = 255), "Compatible.Low.Incomplete"=rgb(255, 255, 153, max = 255),
		"Strong Rejection"=rgb(166, 97, 26, max = 255), "Missing"=rgb(192, 192, 192, max = 255) )
rename.c <- list(
		"Strong Support"="IS_MONO-IS_MONO", "Strong Support (partially missing)"= "IS_MONO_INCOMPLETE-IS_MONO_INCOMPLETE",
		"Weak Support"="IS_MONO-CAN_MONO", "Weak Support (partially missing)"="IS_MONO_INCOMPLETE-CAN_MONO_INCOMPLETE",
		"Compatible (Weak Rejection)"="CAN_MONO-CAN_MONO", "Compatible (Weak Rejection)"="CAN_MONO_INCOMPLETE-CAN_MONO_INCOMPLETE",
		"Compatible (Weak Rejection)"="NOT_MONO-CAN_MONO", "Compatible (Weak Rejection)"="NOT_MONO-CAN_MONO_INCOMPLETE", "Missing"="NO_CLADE-NO_CLADE" ,
		"Strong Rejection"="NOT_MONO-NOT_MONO")
}
#Read Raw files
read.data <- function (file.all="clades.txt", file.hs="clades.hs.txt", clade.order = NULL, techs.order = NULL) {
	raw.all = read.csv(file.all,sep="\t", header=T)
	raw.highsupport = read.csv(file.hs,sep="\t", header=T)
	if (! is.null(techs.order)) {
		print("tech renaming...")
		raw.all$ID=factor(raw.all$ID,levels=techs.order)
		raw.highsupport$ID=factor(raw.highsupport$ID,levels=techs.order)
		print (nrow(raw.all))
		print (nrow(raw.highsupport))
		print("techs renamed!")
	}
	if (! is.null(clade.order)) {
		print("choosing clades...")
		print(levels(raw.all$CLADE))
		print(clade.order)
		raw.all = raw.all[which (raw.all$CLADE %in% clade.order),]
		raw.highsupport = raw.highsupport[which (raw.highsupport$CLADE %in% clade.order),]
		print (nrow(raw.all))
		print (nrow(raw.highsupport))
		print("clades chosen!")
	}
	
	if (! is.numeric(raw.all$BOOT)){
		raw.all$BOOT <- as.numeric(levels(raw.all$BOOT))[raw.all$BOOT]		
	}
	print("bootstrap is numeric")
	raw.highsupport=raw.highsupport[,c(1,2,3,5)]
	# Merge 75% results and all results
	if (FALSE) {
		merged = merge(raw.all,raw.highsupport,c("ID","DS","CLADE"))
	} else {
		merged = cbind(raw.all[,c("ID","DS","CLADE","MONO","BOOT")],raw.highsupport[,c("MONO")])
	}
	names(merged)[4]<-"MONO"
	names(merged)[6]<-"MONO.75"
    print ("merging finished!")
	print (nrow(merged))
	# Create counts table
	clade.counts=recast(merged,MONO+MONO.75~CLADE~DS,id.var=c("DS", "CLADE", "MONO", "BOOT", "MONO.75"))
	print (clade.counts)
	#d.c=d.c/sum(d.c[,1,1])
	countes.melted <- melt(clade.counts)
	names(countes.melted)[1] <- "Classification"
	levels(countes.melted$Classification) <- rename.c
	lo = levels(countes.melted$Classification)
	countes.melted$Classification <- factor(countes.melted$Classification)
	countes.melted <- melt(recast(countes.melted, Classification ~ CLADE ~ DS, fun.aggregate=sum))
	countes.melted <- subset(countes.melted, countes.melted$value != 0)
	countes.melted$Classification <- factor(countes.melted$Classification,levels=lo)
	
	# order clades based on support
	if (is.null(clade.order)) {
		all.monophyletic  <- raw.all[which(raw.all$MONO %in% c("IS_MONO","IS_MONO_INCOMPLETE") ),]
		all.monophyletic$CLADE = reorder(all.monophyletic$CLADE, all.monophyletic$MONO, FUN = function (x) {return (-length(x))})
		clade.order = c(levels(d.boot.mono$CLADE), setdiff(levels(countes.melted$CLADE), levels(d.boot.mono$CLADE)))
	}
	countes.melted$CLADE <- factor(countes.melted$CLADE, levels=clade.order)
	
	
	# Add 75% and normal classifications, and reorder column
	y=merged
	y$Classification <- factor(paste(as.character(merged$MONO),as.character(merged$MONO.75),sep="-"))
	y=y[,c(1,2,3,7)]
	levels(y$Classification) <- rename.c
	y$Classification = factor(y$Classification)
	y.colors <- array(clade.colors[levels(y$Classification)])
	y$CLADE <- factor(y$CLADE, levels=rev(clade.order))
	
	return (list (y=y, countes=clade.counts, countes.melted=countes.melted, raw.all = raw.all, y.colors=y.colors))
}

metabargraph <- function (d.c.m, y){
	
	pdf("Monophyletic_Bargraphs.pdf",width=15,height=10)
	d.c.m.colors <- array(clade.colors[levels(d.c.m$Classification)])
	p1 <- ggplot(d.c.m, aes(x=CLADE, fill=Classification) , main="Support for each clade") + xlab("") + ylab("Number of Gene Trees") + 
			geom_bar(aes(y = value),stat="identity") + facet_wrap(~DS,scales="free_y",ncol=1) + theme_bw()+ 
			theme(axis.text.x = element_text(size=9,angle = 90,hjust=1),legend.position="bottom", legend.direction="horizontal") + 
			scale_fill_manual(name="Classification", values=d.c.m.colors)
	
	print(p1)
	dev.off()
	
	for ( ds in levels(y$DS)) {
		write.csv(file=paste(ds,"counts","csv",sep="."),cast(d.c.m[which(d.c.m$DS == ds),c(1,2,4)],CLADE~Classification))
		for ( clade in levels(y$CLADE)) {
			q <- y[which(y$CLADE == clade & y$DS ==ds),] 
			#print(nrow(q))
			write.csv(file=paste("finegrained/clades",ds,clade,"csv",sep="."),q, row.names=F)
		}
	} 
	
}

metahistograms<- function (d.boot) {
	print(levels(d.boot$DS))
	pdf("Monophyletic_Bootstrap_Support.pdf",width=18,height=18)
	o <- opts(strip.text.x = theme_text(size = 9))
	Main="Distribution of Support for each Clade When Monophyletic and Complete"
	for (l in levels(d.boot$DS)){		
		d.boot.mono  <- d.boot[which(d.boot$MONO == "IS_MONO" & d.boot$DS == l & !is.na(d.boot$BOOT)),]
		d.boot.mono$CLADE = reorder(d.boot.mono$CLADE, d.boot.mono$MONO, FUN = function (x) {return (-length(x))})
		p1 <- qplot(BOOT,data=d.boot.mono,binwidth=5, main = paste(Main," (", l, ")"), xlab="Bootstrap Support")+facet_wrap(~CLADE,scales="free_y") + o
		print(p1)
	}
	
	Main="Distribution of Support for each Clade When Monophyletic but Potentially Incomplete"
	for (l in levels(d.boot$DS)){
		d.boot.mono  <- d.boot[which(d.boot$MONO %in% c("IS_MONO","IS_MONO_INCOMPLETE") & d.boot$DS == l  & !is.na(d.boot$BOOT)),]
		d.boot.mono$CLADE = reorder(d.boot.mono$CLADE, d.boot.mono$MONO, FUN = function (x) {return (-length(x))})
		p1 <- qplot(BOOT,data=d.boot.mono,binwidth=5, main = paste(Main," (", l, ")"), xlab="Bootstrap Support")+facet_wrap(~CLADE,scales="free_y") + o
		print(p1)
	}
	dev.off()	
}

metatable <- function (y,y.colors,c.counts,pages=1:3, figuresizes=c(15,13),raw.all){
	print(levels(y$DS))
	# Draw the block driagram
	for ( ds in levels(y$DS)) {
		
		pdf(paste(ds,"block","pdf",sep="."),width=figuresizes[1],height=figuresizes[2])
		#png(paste(ds,"block","png",sep="."),width=2000,height=2000)#,width=figuresizes[1],height=figuresizes[2])
		
		op <- opts(axis.text.x = theme_text(size=10,angle = 90,hjust=1),legend.position=c(-.15,-.15),axis.text.y = theme_text(hjust=1))
		if (1 %in% pages) {			
			p1 <- qplot(ID,CLADE,data=y,fill=Classification,geom="tile",xlab="",ylab="")+ 
                        scale_x_discrete(drop=FALSE) + scale_y_discrete(drop=FALSE) +
			scale_fill_manual(name="Classification", values=y.colors) + theme_bw() + op
			print(p1)
			
		}
		
		if (2 %in% pages){
			# find clades with no suport
			l=melt(c.counts["IS_MONO-IS_MONO",,ds]+c.counts["IS_MONO-CAN_MONO",,ds])
			nosup = row.names(l)[which(l$value==0)] 		
			y.d <- y[which(y$DS == ds),c(1,3,4)] 
			y.d.r = y.d[which (!y.d$CLADE %in% nosup),]
			y.d.r$CLADE = factor(y.d.r$CLADE)
			p2 <- qplot(ID,CLADE,data=y.d.r,fill=Classification,geom="tile",xlab="",ylab="")+ 
					scale_fill_manual(name="Classification", values=y.colors) + theme_bw() + op
			
			
			print(p2)
		}
		
		if (3 %in% pages) {
			l=melt(c.counts["IS_MONO-IS_MONO",,ds])
			losup = row.names(l)[which(l$value==0)] 		
			y.d.rr = y.d[which (!y.d$CLADE %in% losup),]
			y.d.rr$CLADE = factor(y.d.rr$CLADE)
			
			p3 <- qplot(ID,CLADE,data=y.d.rr,fill=Classification,geom="tile",xlab="",ylab="")+ 
					scale_fill_manual(name="Classification", values=y.colors)+ theme_bw() + op 
			
			
			print(p3)
		}
		dev.off()
		db=raw.all[raw.all$MONO=="IS_MONO",]
                dbc=y[which(y$Classification=="Compatible (Weak Rejection)"),1:3]
		dbn=y[which(y$Classification=="Strong Rejection"),1:3]
                dbc$BOOT=-100; 
		dbn$BOOT=-200;		
                db2=rbind(dbn[,cols],dbc[,cols],db[,cols]);
                db2$CLADE <- factor(db2$CLADE, levels=rev(clade.order)) 
		nrow(db2)
		pdf(paste(ds,"block-shades","pdf",sep="."),width=figuresizes[1],height=figuresizes[2]) 
                p1 <- qplot(ID,CLADE,data=db2,fill=BOOT,geom="tile",xlab="",ylab="")+
		      scale_x_discrete(drop=FALSE) + scale_y_discrete(drop=FALSE)+
		      scale_fill_gradient2(high="green4",mid="lightgreen",low="tomato",na.value="steelblue3")+ 
		      theme_bw() + theme(axis.text.x = theme_text(size=10,angle = 90,hjust=1),axis.text.y = theme_text(hjust=1),legend.position="None")
		print(p1)
		dev.off()
		write.csv(file=paste(ds,"metatable.results","csv",sep="."),cast(y,ID~CLADE))		
	}
}

#ggplot(d.c.m, aes(x = CLADE, y = value)) + geom_bar() + aes(fill = variable)+
#	scale_x_discrete("Techniques",labels=inTechs.rename,breaks=inTechs)+					
#	opts(axis.text.x = theme_text(angle = 45)) + # to make the axis legend vertical
#	facet_grid(~ DS)
