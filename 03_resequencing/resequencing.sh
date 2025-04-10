#1. index
java -Xmx2g -jar CreateSequenceDictionary.jar R=TS-RS1.genome.fasta O= TS-RS1.genome.dict
bwa index -a bwtsw TS-RS1.genome.fasta
samtools faidx TS-RS1.genome.fasta

#2. bwa
while read line
do
echo bwa mem -t 5 -M -R \"@RG\\tID:id1\\tPL:illumina\\tSM:\'${line}\'\" TS-RS1.genome.fasta ${line}_1.fq.gz ${line}_2.fq.gz \|samtools view -bS - \|samtools sort -@ 5 -o ${line}.bwa.sort.bam  >> execute.bwa
echo samtools rmdup -S ${line}.bwa.sort.bam ${line}.bwa.rmdup.bam >> execute.bwa
echo samtools index ${line}.bwa.rmdup.bam >> execute.bwa
echo java -Xms10g -Xmx10g -jar BuildBamIndex.jar VALIDATION_STRINGENCY=SILENT TMP_DIR=TFW01 I=${line}.bwa.rmdup.bam >> execute.bwa
echo rm ${line}.bwa.sort.bam  >> execute.bwa
done < RIL_RS_id.list
bash execute.bwa

#3. gatk
while read line
do
echo java -Xms10g -Xmx10g -jar GenomeAnalysisTK.jar -T HaplotypeCaller -R TS-RS1.genome.fasta -I ../01_alin/${line}.bwa.rmdup.bam --emitRefConfidence GVCF --variant_index_type LINEAR --variant_index_parameter 128000 -o ${line}.gatk.gvcf -stand_call_conf 30.0 -stand_emit_conf 40.0 -nct 30 >> execute.vcf
done < RIL_RS_id.list
bash execute.vcf
#merge
ls *gvcf| awk '{print " --variant "$1}'|awk -F '\t' '{for(i=0;++i<=NF;)a[i]=a[i]?a[i] FS $i:$i}END{for(i=0;i++
<NF;)print a[i]}'|awk '{print "java -Xmx20g -jar GenomeAnalysisTK.jar -T CombineGVCFs -R TS-RS1.genome.fasta -o all.gatk.gvcf "$0}'|sed 's/\t/ /g' > 03_merge.sh
bash 03_merge.sh
java -Xmx20g -jar GenomeAnalysisTK.jar -T GenotypeGVCFs -R TS-RS1.genome.fasta --variant all.gatk.gvcf -o all.popu.vcf
#merge indel
java -Xms20g -Xmx20g -jar GenomeAnalysisTK.jar -T SelectVariants -R TS-RS1.genome.fasta --variant all.popu.vcf -o all.raw_indels.vcf -selectType INDEL
#filter indel
java -Xms20g -Xmx20g -jar GenomeAnalysisTK.jar -T VariantFiltration -R TS-RS1.genome.fasta  -o all.final.indels.vcf --variant all.raw_indels.vcf --filterExpression "QD < 2.0 ||  FS >200.0 || ReadPosRankSum < -20.0" --filterName "InDelsfilter"
#PASS indel
perl -ne 'print if /^#/ or /PASS/' all.final.indels.vcf > all_chr.final.pass.indels.vcf
#merge snp
java -Xms20g -Xmx20g -jar GenomeAnalysisTK.jar -T SelectVariants -R TS-RS1.genome.fasta --variant all.popu.vcf -o all.raw_snps.vcf -selectType SNP
#filter snp
java -Xms20g -Xmx20g -jar GenomeAnalysisTK.jar -T VariantFiltration -R TS-RS1.genome.fasta -o all.final.snps.vcf --variant all.raw_snps.vcf --filterExpression "QD < 2.0 || MQ < 40.0 || FS > 60.0 || MQRankSum < -12.5 || ReadPosRankSum < -8.0" --filterName "SNPsfilter" --clusterSize 3 --clusterWindowSize 10
#PASS snp
perl -ne 'print if /^#/ or /PASS/' all.final.snps.vcf > all_chr.final.pass.snps.vcf


