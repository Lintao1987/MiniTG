#01. Variation detection
nucmer --mum --mincluster=100 TS-RS1.genome.new.fasta TS-RS2.genome.new.fasta -p TS-RS1_TS-RS2
delta-filter -l 1000 TS-RS1_TS-RS2.delta -1 > TS-RS1_TS-RS2.filter
show-coords -THrd TS-RS1_TS-RS2.filter > TS-RS1_TS-RS2.filter.coords
mummerplot -p TS-RS1_TS-RS2.filter -t postscript TS-RS1_TS-RS2.filter
ps2pdf TS-RS1_TS-RS2.filter.ps TS-RS1_TS-RS2.filter.pdf
syri -c TS-RS1_TS-RS2.filter.coords -d TS-RS1_TS-RS2.filter -r TS-RS1.genome.new.fasta.no0 -q TS-RS2.genome.new.fasta.no0
plotsr syri.out TS-RS1.genome.new.fasta.no0 TS-RS2.genome.new.fasta.no0 -H 8 -W 5
mv syri.pdf TS-RS1_TS-RS2.pdf
mv syri.log TS-RS1_TS-RS2.log
mv syri.summary TS-RS1_TS-RS2.summary
mv syri.vcf TS-RS1_TS-RS2.vcf
mv syri.out TS-RS1_TS-RS2.out

#vg
vg construct -r index/TS-RS1.genome.new.fasta.no0 -v index/All.vcf.gz > TS-RS1_TS-RS2.vg
vg autoindex --workflow giraffe -r index/TS-RS1.genome.new.fasta.no0 -v index/All.vcf.gz -R XG -p TS-RS1_TS-RS2
vg convert TS-RS1_TS-RS2.xg -p > TS-RS1_TS-RS2.pg
vg snarls TS-RS1_TS-RS2.pg > TS-RS1_TS-RS2.snarls

#giraffe
while read line
do
echo vg giraffe -x ../04_giraffe/TS-RS1_TS-RS2.xg -m ../04_giraffe/TS-RS1_TS-RS2.min -d ../04_giraffe/TS-RS1_TS-RS2.dist -N ${line} -Z ../04_giraffe/TS-RS1_TS-RS2.giraffe.gbz -f /public200T/lintao_cau/suxiao/work/TS-RS1/01_data/RIL_reseq/${line}/${line}_1.fq.gz -f /public200T/lintao_cau/suxiao/work/TS-RS1/01_data/RIL_reseq/${line}/${line}_2.fq.gz -t 10 \> ${line}.gam >> 01_alin.sh
echo vg augment ../04_giraffe/TS-RS1_TS-RS2.pg ${line}.gam -m 2 -q 3 -Q 3 -t 10 -A ${line}.aug.gam \> ${line}.aug.pg >> 01_alin.sh
echo vg snarls ${line}.aug.pg \> ${line}.aug.snarls >> 01_alin.sh
echo vg pack -x ${line}.aug.pg -g ${line}.aug.gam -o ${line}.aug.pack >> 01_alin.sh
echo vg call ${line}.aug.pg -r ${line}.aug.snarls -k ${line}.aug.pack -s ${line} \> ${line}.vcf >> 01_alin.sh
echo bgzip ${line}.vcf >> 01_alin.sh
echo tabix ${line}.vcf.gz >> 01_alin.sh
done < RIL_RS_id.list
bash 01_alin.sh
ls |grep gz|grep -v tbi > sample.list
cat sample.list |awk '{for(i=0;++i<=NF;)a[i]=a[i]?a[i] FS $i:$i}END{for(i=0;i++<NF;)print a[i]}'|awk '{print "vcf-merge "$0" > all.vcf"}'|sed '1i #!/bin/bash' > 02_merge.sh
bash 02_merge.sh
vcftools --minDP 3 --maxDP 100 --minGQ  10 --minQ 30 --min-meanDP 3 --out all.miss0.2.maf0.01.vcf --vcf all.vcf --recode --recode-INFO-all --max-missing 0.2 --maf 0.01

