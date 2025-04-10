while read line
do
featureCounts -p -a TS-RS1.new.gtf -o ${line}.txt -T 6 -t exon -g gene_id ../01_alin/${line}.sort.bam
done < RIL_RS_id.list
