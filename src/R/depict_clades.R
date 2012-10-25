require(ggplot2)

rename.c <- list(
		  "Mono.High"="IS_MONO-IS_MONO","Mono.High.Incomplete"= "IS_MONO_INCOMPLETE-IS_MONO_INCOMPLETE",
                  "Mono.Low"="IS_MONO-CAN_MONO", "Mono.Low.Incomplete"="IS_MONO_INCOMPLETE-CAN_MONO_INCOMPLETE",
		  "Compatible.Low"="NOT_MONO-CAN_MONO", "Compatible.Low.Incomplete"="NOT_MONO-CAN_MONO_INCOMPLETE",
		  "NotMono.High"="NOT_MONO-NOT_MONO",
		  "NoClade"="NO_CLADE-NO_CLADE" )

clade.colors <- c("Mono.High"=rgb(51, 160, 44, max = 255), "Mono.High.Incomplete"=rgb(178, 223, 138, max = 255),
		 "Mono.Low"=rgb(31, 120, 180, max = 255), "Mono.Low.Incomplete"=rgb(166, 206, 227, max = 255),
		  "Compatible.Low"=rgb(253, 192, 134, max = 255), "Compatible.Low.Incomplete"=rgb(255, 255, 153, max = 255),
		  "NotMono.High"=rgb(227, 26, 28, max = 255), "NoClade"=rgb(192, 192, 192, max = 255) )

#techs = c("4fould-mreCons-Aug15","C3.mre.Aug15","Dna.unpart_best","Dna.unpart_mreConsensus","Dna.part123_best","Dna.part123_mreConsensus","Exon2500.bestWSupport.vSept19","Exon2500.mreConsensus.vSept19","C1.mre","C2.mre.Aug15","Dna.part12_best","Dna.part12_mreConsensus","Pep.part_best","Pep.part.mreConsensus","Pep.unpart_best","Pep.unpart_mreConsensus","Intron-part-bestWSupport.vSept18","Intron-part-mreConsensus.vSept18","Intron-part-secondbestWSupport.vSept18","Intron-unpart-best.vsept18","Intron-unpart-mreConsensus.vsept18","Mpest_aa_k8_cons-v.July17","Mpest_bird_dna12_corrected_con.v-May_30.nexus","Mpest_dna3pos_k8_cons-v.July17","Mpest.intron-v-shortname", "UCE-3761-raxml-1000-100bstrap","UCE-4097-raxml-1000-100bstrap")

#techs = c("Supermatrix; Amino Acid:","FAA.untrimmed.unpartitioned","FAA.trim50genes.unpartitioned","FAA.trim50genesChara.allPos.unpartitioned","FAA.trim50genes50sites.unpartitioned","FAA.trim50genes50sites.clustered.partitioned","Supermatrix; Codon - 1st and 2nd:","FNA2AA.untrimmed.no3rd.unpartitioned","FNA2AA.trim50genes.no3rd.unpartitioned","FNA2AA.trim50genesChara.no3rd.unpartitioned","FNA2AA.trim50genes50sites.no3rd.unpartitioned","FNA2AA.trim50genes50sites.no3rd.partitioned","Supertree; Amino Acid + Codon 1st and 2nd:","supertree.FAA.unpartitioned.boostrap","supertree.FAA.trim50genes.unpartitioned.boostrap","supertree.FNA2AA.no3rd.unpartitioned.boostrap","supertree.FNA2AA.trim50genes.no3rd.unpartitioned.boostrap","Supertree; Codon + DNA:","supertree.FNA.unpartitioned.boostrap","supertree.FNA.trim50genes.unpartitioned.boostrap","supertree.FNA2AA.allPos.unpartitioned.boostrap","supertree.FNA2AA.trim50genes.allPos.unpartitioned.boostrap","Supermatrix; Codon - all 3 positions + DNA:", "FNA2AA.untrimmed.allPos.unpartitioned","FNA2AA.trim50genesChara.allPos.unpartitioned","FNA2AA.trim50genes.allPos.unpartitioned","FNA2AA.trim50genes50sites.allPos.unpartitioned","FNA2AA.trim50genes50sites.allPos.partitioned","FNA.trim50genes50sites.unpartitioned")

clade.order= c("Sister to Land Plants:","Zygnemophyceae","LandPlants","Coleochaetales","CharaColeochaetales","ColeochaetalesZygnemophyceae","ZygnemophyceaeLandPlants","CharaLandPlants","ColeochaetalesLandPlants","ColeochaetalesZygnemophyceaeLandPlants","CharaColeochaetalesLandPlants","Bryophyte Relations:", "Anthocerophyta","Bryophyta","Marchantiophyta","Tracheophytes","BryophytaMarchantiophyta","BryophytaMarchantiophytaAnthocerophyta","AnthocerophytaTracheophytes","BryophytaTracheophytes","BryophytaTracheophytesAnthocerophyta","BryophytaMarchantiophytaTracheophytes","GymnoSperm:","Gnetales","Pinaceae","ConiferalesNoPinaceae","Cycads","GnetalesPinaceae","Coniferales","ConiferalesGnetales","GinkgoCycads","GinkgoCycadsConiferales","GinkgoCycadsConiferalesGnetales","Angiosperms: ","Eudicots","Magnoliids","Monocots","EudicotsMagnoliids","EudicotsMagnoliidsChloranthales","MagnoliidsChloranthales","MagnoliidsChloranthalesMonocots","MonocotsEudicots","MonocotsMagnoliids","Basal Angiosperms: ","AmborelaNuphar","AngioSperms","AngioSpermsNoAmborela","AngioSpermsNoAmborelaNuphar")

#Read Raw files
d.boot = read.csv("clades.txt",sep=" ", header=T)
d.75 = read.csv("clades.75.txt",sep=" ", header=T)
if (! is.numeric(d.boot$BOOT)){
	d.boot$BOOT <- as.numeric(levels(d.boot$BOOT))[d.boot$BOOT]
}
d.75=d.75[,c(1,2,3,5)]
#d.boot$ID=factor(d.boot$ID,levels=techs)
#d.75$ID=factor(d.75$ID,levels=techs)
# Merge 75% results and all results
if (FALSE) {
 d = merge(d.boot,d.75,c("ID","DS","CLADE"))
} else {
 d=cbind(d.boot[,c("ID","DS","CLADE","MONO","BOOT")],d.75[,c("MONO")])
}
names(d)[4]<-"MONO"
names(d)[6]<-"MONO.75"
# Create counts table
d.c=recast(d,MONO+MONO.75~CLADE~DS)/2
d.c.m <- melt(d.c)
names(d.c.m)[1] <- "Classification"
d.c.m <- subset(d.c.m, d.c.m$value != 0)
# order clades based on support
d.boot.mono  <- d.boot[which(d.boot$MONO == "IS_MONO"),]
d.boot.mono$CLADE = reorder(d.boot.mono$CLADE, d.boot.mono$MONO, FUN = function (x) {return (-length(x))})
#clade.order = c(levels(d.boot.mono$CLADE), setdiff(levels(d.c.m$CLADE), levels(d.boot.mono$CLADE)))
d.c.m$CLADE <- factor(d.c.m$CLADE, levels=clade.order)
levels(d.c.m$Classification) <- rename.c
d.c.m$Classification <- factor(d.c.m$Classification)

clade.colors <- array(clade.colors[levels(d.c.m$Classification)])

# Add 75% and normal classifications, and reorder column
y=d
y$Classification <- factor(paste(as.character(d$MONO),as.character(d$MONO.75),sep="-"))
y=y[,c(1,2,3,7)]
levels(y$Classification) <- rename.c
y$Classification = factor(y$Classification)
y$CLADE <- factor(y$CLADE, levels=rev(clade.order))


for ( ds in levels(y$DS)) {
  write.csv(file=paste(ds,"counts","csv",sep="."),cast(d.c.m[which(d.c.m$DS == ds),c(1,2,4)],CLADE~Classification))
  for ( clade in levels(y$CLADE)) {
    q <- y[which(y$CLADE == clade),] 
    #print(nrow(q))
    write.csv(file=paste("finegrained/clades",ds,clade,"csv",sep="."),q, row.names=F)
  }
} 


pdf("Monophyletic_Bootstrap_Support.pdf",width=18,height=18)
o <- opts(strip.text.x = theme_text(size = 9))
Main="Distribution of Support for each Clade When Monophyletic and Complete"
for (l in levels(d.boot$DS)){
  d.boot.mono  <- d.boot[which(d.boot$MONO == "IS_MONO" & d.boot$DS == l ),]
  d.boot.mono$CLADE = reorder(d.boot.mono$CLADE, d.boot.mono$MONO, FUN = function (x) {return (-length(x))})
  p1 <- qplot(BOOT,data=d.boot.mono,binwidth=5, main = paste(Main," (", l, ")"), xlab="Bootstrap Support")+facet_wrap(~CLADE,scales="free_y") + o
  print(p1)
}

Main="Distribution of Support for each Clade When Monophyletic but Potentially Incomplete"
for (l in levels(d.boot$DS)){
  d.boot.mono  <- d.boot[which(d.boot$MONO %in% c("IS_MONO","IS_MONO_INCOMPLETE") & d.boot$DS == l ),]
  d.boot.mono$CLADE = reorder(d.boot.mono$CLADE, d.boot.mono$MONO, FUN = function (x) {return (-length(x))})
  p1 <- qplot(BOOT,data=d.boot.mono,binwidth=5, main = paste(Main," (", l, ")"), xlab="Bootstrap Support")+facet_wrap(~CLADE,scales="free_y") + o
  print(p1)
}
dev.off()


pdf("Monophyletic_Bargraphs.pdf",width=16,height=12)
p1 <- ggplot(d.c.m, aes(CLADE, y = value, fill=Classification) , main="Support for each clade") + xlab("Clades") + ylab("Tree Count") + 
	geom_bar() + facet_grid(DS~.) + opts(axis.text.x = theme_text(size=8,angle = 90)) + 
	scale_fill_manual(name="Classification", 
		 values=clade.colors)

print(p1)
dev.off()


print(levels(y$DS))
# Draw the block driagram
for ( ds in levels(y$DS)) {

 # find clades with no suport
  l=melt(d.c[2,,ds]+d.c[1,,ds])
  nosup = row.names(l)[which(l$value==0)] 
  l=melt(d.c[2,,ds])
  losup = row.names(l)[which(l$value==0)] 

  y.d <- y[which(y$DS == ds),c(1,3,4)] 
  y.d.r = y.d[which (!y.d$CLADE %in% nosup),]
  y.d.r$CLADE = factor(y.d.r$CLADE)
  y.d.rr = y.d[which (!y.d$CLADE %in% losup),]
  y.d.rr$CLADE = factor(y.d.rr$CLADE)

  pdf(paste(ds,"block","pdf",sep="."),width=25,height=12)
  p1 <- qplot(ID,CLADE,data=y.d,fill=Classification,geom="tile",xlab="",ylab="")+ 
               scale_fill_manual(name="Classification", values=clade.colors) +
               opts(axis.text.x = theme_text(size=8,angle = 90),legend.position=c(0.12,0.1))
  print(p1)
  p2 <- qplot(ID,CLADE,data=y.d.r,fill=Classification,geom="tile",xlab="",ylab="")+ 
               scale_fill_manual(name="Classification", values=clade.colors) +
               opts(axis.text.x = theme_text(size=8,angle = 90),legend.position=c(0.12,0.1))


  print(p2)
  p3 <- qplot(ID,CLADE,data=y.d.rr,fill=Classification,geom="tile",xlab="",ylab="")+ 
               scale_fill_manual(name="Classification", values=clade.colors) +
               opts(axis.text.x = theme_text(size=8,angle = 90),legend.position=c(0.12,0.1))


#  print(p3)
  dev.off()

  write.csv(file=paste(ds,"results","csv",sep="."),cast(y,ID~CLADE))
  
}

#ggplot(d.c.m, aes(x = CLADE, y = value)) + geom_bar() + aes(fill = variable)+
#	scale_x_discrete("Techniques",labels=inTechs.rename,breaks=inTechs)+					
#	opts(axis.text.x = theme_text(angle = 45)) + # to make the axis legend vertical
#	facet_grid(~ DS)
