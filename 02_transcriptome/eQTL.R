#!~/bin/R
#coding:utf-8

snp <- read.table('total.genotype.new',header=T,row.names=1)
fpkm <- read.table('TS-RS1_all_TPM.txt',header=T,row.names=1)
library("MatrixEQTL")

options(scipen=200)

snps = SlicedData$new()    
snps$fileDelimiter = "\t"
snps$fileOmitCharacters = "NA" 
snps$fileSkipRows = 1 
snps$fileSkipColumns = 1 
snps$fileSliceSize = 2000 
snps$LoadFile("total.genotype.new")

gene = SlicedData$new() 
gene$fileDelimiter = "\t" 
gene$fileOmitCharacters = "NA" 
gene$fileSkipRows = 1 
gene$fileSkipColumns = 1 
gene$fileSliceSize = 2000 
gene$LoadFile("TS-RS1_all_TPM.txt")

covariates_file_name = character()
cvrt = SlicedData$new()
cvrt$fileDelimiter = "\t"
cvrt$fileOmitCharacters = "NA"
cvrt$fileSkipRows = 1
cvrt$fileSkipColumns = 1
if(length(covariates_file_name)>0) {cvrt$LoadFile(covariates_file_name)}

snpspos =read.table('RIL_SNP_POS_final.txt', header = TRUE, stringsAsFactors = FALSE)
genepos =read.table('TS-RS1_FPKM_POS.txt', header = TRUE, stringsAsFactors = FALSE)

output_file_name_cis = tempfile()
output_file_name_tra = tempfile()
errorCovariance = numeric()
cisDist = 5e4
useModel = modelLINEAR
pvOutputThreshold_cis = 1e-2
pvOutputThreshold_tra = 1e-4

me = Matrix_eQTL_main(snps = snps,gene = gene,cvrt = cvrt,
output_file_name =output_file_name_tra, pvOutputThreshold = pvOutputThreshold_tra,
useModel = useModel, errorCovariance = errorCovariance,verbose = TRUE,
output_file_name.cis  =output_file_name_cis,pvOutputThreshold.cis =pvOutputThreshold_cis,
snpspos = snpspos,genepos = genepos,cisDist = cisDist,
pvalue.hist = "qqplot",min.pv.by.genesnp = FALSE,noFDRsaveMemory= FALSE)

unlink(output_file_name_tra);
unlink(output_file_name_cis);

cat('Analysis done in: ', me$time.in.sec, ' seconds', '\n');
cat('Detected local eQTLs:', '\n');
show(me$cis$eqtls)
cat('Detected distant eQTLs:', '\n');
show(me$trans$eqtls)

## Plot the Q-Q plot of local and distant p-values

plot(me)
dev.off()

write.table(me$trans$eqtls, file = "trans.eqtls.txt")
write.table(me$cis$eqtls, file = "cis.eqtls.txt")

