#1. vcf to gen
python3 VcfToGen.py all.vcf finalmafmis_SNP.gen

#2. MLM gwas
plink --file finalmafmis_SNP.gen --indep-pairwise 50 5 0.8 --maf 0.05
grep -Fwf plink.prune.in finalmafmis_SNP.gen > finalmafmis_SNP_LD0.8.gen
gtool -G --g finalmafmis_SNP_LD0.8.gen --s final.sample
plink --file finalmafmis_SNP_LD0.8.gen --pca --out PCA
cat PCA.eigenvec |awk '{print $1,$2,"1",$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22}'|sed 's/ /\t/g' > PCA.txt
plink --file finalmafmis_SNP.gen --recode12 --output-missing-genotype 0 --transpose --out finalmafmis_SNP.gen
plink --file finalmafmis_SNP.gen --make-bed --out finalmafmis_SNP.gen
java -jar gec.jar -Xmx1g --effect-number --plink-binary ./finalmafmis_SNP.gen --genome --out finalmafmis_SNP.gen
emmax-kin -v -h -d 10 finalmafmis_SNP.gen
# Association with PCA and kinship as cofactor
while read line
do
mkdir ${line}
emmax -v -d 10 -t finalmafmis_SNP.gen -p ${line} -k finalmafmis_SNP.gen.hBN.kinf -c PCA.txt -o ./${line}/EMMAX_Trait_out
python3 transtoqqman.py ./${line}/EMMAX_Trait_out.ps ./${line}/qqman.tsv
cp ./Manhattan.R ./${line}
cd ./${line}
Rscript ./Manhattan.R #graph
cd ../
done < phenotype.list

#3. LASSO gwas
#weight
while read line
do
python3 cis_SNP.py -i1 RIL_SNP_POS_final.txt -i2 cis.eqtls.txt -i3 all.gen -g ${line} -o ${line}.gen
cat TS-RS1_all_TPM.txt|grep ${line} |cat header - |awk '{for(i=0;++i<=NF;)a[i]=a[i]?a[i] FS $i:$i}END{for(i=0;i++<NF;)print a[i]}'|awk '{print $1,$1,"0","0","0",$2}'|grep -v 'gene_id' > ${line}.a
python3 sort.py ${line}.a final.sample ${line}.b
cat ${line}.b|awk '{print $1,$2,$6}' > ${line}.tpm
gtool -G --g ${line}.gen --s final.sample
plink --file ${line}.gen --pheno ${line}.tpm --recode --out ${line}.gen.new
plink --file ${line}.gen.new --make-bed --out ${line}.gen.new
Rscript fusion_twas-master/FUSION.compute_weights.R --bfile ${line}.gen.new --tmp tmp_${line} --out WEIGHT/${line} --models top1,lasso,enet --hsq_set 0 --PATH_gcta gcta64
rm ${line}.* rm tmp_${line}*
done < gene.list

mkdir REF
cd REF
for i in 1 2 3 4 5 6 7 8 9 10 11 12
do
cat finalmafmis_SNP.gen|awk "{if(\$1=="${i}")print \$0}" > finalmafmis_SNP.gen.${i}
gtool -G --g finalmafmis_SNP.gen.${i} --s final.sample
plink --file finalmafmis_SNP.gen.${i} --recode12 --output-missing-genotype 0 --transpose --out finalmafmis_SNP.gen.${i}
plink --file finalmafmis_SNP.gen.${i} --make-bed --out finalmafmis_SNP.gen.${i}
done
cd ../
for i in {1..12}
do
cat ./REF/finalmafmis_SNP.gen.${i}|awk '{print $2,$1,$3,$4,$5}' > finalmafmis_SNP.gen.${i}.pos
done
cat finalmafmis_SNP.gen.1.pos finalmafmis_SNP.gen.2.pos finalmafmis_SNP.gen.3.pos finalmafmis_SNP.gen.4.pos finalmafmis_SNP.gen.5.pos finalmafmis_SNP.gen.6.pos finalmafmis_SNP.gen.7.pos finalmafmis_SNP.gen.8.pos finalmafmis_SNP.gen.9.pos finalmafmis_SNP.gen.10.pos finalmafmis_SNP.gen.11.pos finalmafmis_SNP.gen.12.pos > finalmafmis_SNP.gen.pos

while read line
do
mkdir ${i}
cat ${i}/EMMAX_Trait_out.ps |awk '{print $2,$3,$4}'|paste ../finalmafmis_SNP.gen.pos - |sed 's/ /\t/g'|sed '1i snpid\thg18chr\tbp\ta1\ta2\tbeta\tse\tpval' > ${i}/${i}.ps
python ldsc-master/munge_sumstats.py --sumstats ${i}/${i}.ps --N 230 --out ${i}/${i} --a1-inc
gunzip ${i}/${i}.sumstats.gz
for j in {1..12}
do
Rscript fusion_twas-master/FUSION.assoc_test.new.R --sumstats ${i}/${i}.sumstats --weights WEIGHT.pos --weights_dir ./ --ref_ld_chr ../REF/finalmafmis_SNP.gen. --chr ${j} --out ${i}/${i}.${j}.dat
done
done
cd ../

