#png("1.png")
library(CMplot)
data<-read.table("qqman.csv",header = TRUE,sep="\t")
CMplot(data, plot.type="m", multracks=TRUE, threshold=c(0.01,0.05)/nrow(data),threshold.lty=c(1,2), 
threshold.lwd=c(1,1), threshold.col=c("black","grey"), amplify=TRUE,bin.size=1e6,
chr.den.col=c("darkgreen", "yellow", "red"), 
file="jpg",memo="",dpi=300,file.output=TRUE,verbose=TRUE)
